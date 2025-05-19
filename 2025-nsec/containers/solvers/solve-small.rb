require 'json'
require 'base64'

def get_tags(repo = "small")
  images = `docker image ls --format json`.lines.map { JSON.parse it }.select do |img|
    img["Repository"] == repo
  end.map do |img|
    "#{repo}:#{img["Tag"]}"
  end
end

def read_file(tag, glob)
  `docker run --rm -it --entrypoint sh --platform=linux/amd64 #{tag} -c 'cat #{glob}'`
end

tags = get_tags

def solve(tag)
  code, data = read_file(tag, "/[0-9]*").split('__END__')
  data = data.split.map(&:to_i)
  code = Base64.decode64(JSON.parse(code.split('decode64(').last.split('.').first).map{it.chr}.join)
  xor = JSON.parse(code.lines.first.split(?")[1]).map{it.chr}.join.to_i
  password = data.map{it ^ xor}.pack('C*')
end

def get_flag_part(tag)
  password = solve(tag)
  puts "#{tag} #{password}"
  output = `IMAGE=#{tag} INPUT=#{password} expect ./run.expect`
  part = output[/part (\d+)/, 1].to_i
  flag = output[/Here it is: ([-FLAGa-f0-9]+)/, 1]
  [part, flag]
end

flag = tags.map do |tag|
  puts "solving #{tag}..."
  get_flag_part(tag).tap do |f|
    puts "got: #{f.last.inspect}"
  end
end.sort.map(&:last).join

puts "flag: #{flag}"
