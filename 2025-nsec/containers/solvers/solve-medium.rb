require 'json'
require 'base64'
require 'rubygems/package'
require 'stringio'

def get_tags(repo = "medium")
  images = `docker image ls --format json`.lines.map { JSON.parse it }.select do |img|
    img["Repository"] == repo
  end.map do |img|
    "#{repo}:#{img["Tag"]}"
  end
end

tags = get_tags

def analyze_history(tag)
  h = `docker history --format json --no-trunc #{tag}`.lines.map { JSON.parse it }

  build_step = h.find do |step|
    step["CreatedBy"].include?("go build")
  end

  env_step = h.find do |step|
    step["CreatedBy"].include?("X=")
  end

  xor2 = build_step.to_s[/main.pff=(\d+)/, 1].to_i
  xor1 = env_step["CreatedBy"][/X=(\d+)/, 1].to_i

  [xor1, xor2]
end

def get_layer_with_source(tag)
  manifest = JSON.parse(`docker image inspect --format json #{tag}`).first
  # index of the layer that copied the source code into the image
  diff_id = manifest["RootFS"]["Layers"][-3]
end

def get_source(tag)
  diff_id = get_layer_with_source(tag).sub(?:, ?/)

  Gem::Package::TarReader.new(File.open("medium.tar")) do |tar|
    tar.each do |entry|
      next unless entry.full_name[diff_id]

      Gem::Package::TarReader.new(StringIO.new(entry.read)) do |layer|
        layer.each do |entry|
          return entry.read
        end
      end
    end
  end
end

def solve(tag)
  xor1, xor2 = analyze_history(tag)
  source = get_source(tag)
  input = source.split('`')[1]

  password = input.split(' ').select{ it[?:] }.map do
    char, idx = it.split(?:).map(&:to_i)
    char = char ^ xor1
    idx = (idx ^ xor2)
    [idx, char.chr]
  end.sort.map(&:last).join
end

def get_flag_part(tag)
  password = solve(tag)
  output = `IMAGE=#{tag} INPUT=#{password} expect ./run.expect`
  part = output[/part (\d+)/, 1].to_i
  flag = output[/Here it is: ([-FLAGa-z0-9]+)/, 1]
  [part, flag]
end

flag = tags.map do |tag|
  puts "solving #{tag}..."
  get_flag_part(tag).tap do |f|
    puts "got: #{f.last.inspect}"
  end
end.sort.map(&:last).join

puts "flag: #{flag}"
