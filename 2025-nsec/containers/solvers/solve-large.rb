require 'json'
require 'base64'
require 'rubygems/package'
require 'stringio'
require 'shellwords'

def get_tags(repo = "large")
  `docker image ls --format json`.lines.map { JSON.parse it }.select do |img|
    img["Repository"] == repo
  end.map do |img|
    "#{repo}:#{img["Tag"]}"
  end.sort_by do |tag|
    tag.split(":p").last.to_i
  end
end

tags = get_tags

def get_flag_part(tag)
  password = solve(tag)
  puts "#{tag} #{password}"
  output = `IMAGE=#{tag} INPUT=#{password} expect ./run.expect`
  part = output[/part (\d+)/, 1].to_i
  flag = output[/Here it is: ([-FLAGa-f0-9]+)/, 1]
  [part, flag]
end

class Container
  def initialize(tag)
    @tag = tag
  end

  def start(&block)
    @id = `docker run -d --rm --platform=linux/amd64 --entrypoint sh #{@tag} -c 'sleep infinity'`.strip
    block.call(self).tap do
      `docker kill #{@id}`
    end
  end

  def run_cmd(cmd, workdir: "/")
    `docker exec --workdir #{workdir} #{@id} sh -c #{Shellwords.escape(cmd)}`
  end

  def read_file(path)
    run_cmd("cat < #{Shellwords.escape(path)}")
  end

  def write_file(path, content)
    run_cmd("echo #{Shellwords.escape(content)} > #{Shellwords.escape(path)}")
  end
end

def solve(tag)
  Container.new(tag).start do |c|
    # find the bun script
    run_bun = c.run_cmd("cat $LP | xargs -n1 sh -c 'test -f $0 && echo $0' | xargs -n1 sh -c 'cat < $0' | grep LB=")
    bun_script_path = JSON.parse(run_bun.split[2])
    original_bun_script = c.read_file(bun_script_path)

    # patch bun script to print state at the end of a wrong input
    print_state = 'console.log(JSON.stringify(K))';
    print_script = original_bun_script.sub('if(K.every(R(0)))process.exit(0);else process.exit(1)', print_state)

    c.write_file(bun_script_path, print_script)

    test_input = "0" * 32
    offset = JSON.parse(c.run_cmd("echo #{test_input} | $E"))

    # add the wrong state to the wrong input
    password = test_input.bytes
    offset.each.with_index do |o, i|
      password[i] += o
    end
    password = password.pack("c*")
  end
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

puts flag
