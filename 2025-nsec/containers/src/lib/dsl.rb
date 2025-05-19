require "openssl"
require "base64"
require "erb"
require "shellwords"
require "securerandom"
require "json"

IMAGES = {
  go: "golang:alpine@sha256:2c49857f2295e89b23b28386e57e018a86620a8fede5003900f2d138ba9c4037",
  ruby: "ruby:3.4.1-alpine@sha256:e5c30595c6a322bc3fbaacd5e35d698a6b9e6d1079ab0af09ffe52f5816aec3b",
  bun: "oven/bun:latest@sha256:0805b993b27de973af29184dafcde64622e0aeeb9169ddc0580892708f0ced72",
}

def hmac(key, message)
  Base64.urlsafe_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), key, message))
end

def sha256(data)
  OpenSSL::Digest.new("sha256").new.hexdigest(data)
end

def sha256_bin(data)
  OpenSSL::Digest.new("sha256").new.digest(data)
end

def chunk(str, n)
  raise 'str cannot be chunked' if str.size % n != 0
  str.chars.each_slice(str.size / n).map(&:join)
end

# convert number into a list of numbers whose sum is n
def partition(n)
  parts = []
  i = 0
  max_size = rand(3) + 2
  while parts.sum != n && i < max_size
    parts << rand(n*2)-n
    i += 1
  end
  parts << n - parts.sum
  parts.map {
   if it < 0
     ['-', it.abs]
   else
     ['+', it]
   end
  }.tap do
    puts it.inspect
  end
end

def test_container(solutions: [], contains: "Congrats")
  puts "testing solutions..."
  solutions.each.with_index do |part, i|
    if `INPUT=#{part} IMAGE=#{TAG}:p#{i+1} ./test.expect`[contains]
      print '.'
      next
    end
    puts
    puts "part #{i} failed: output did not contain `#{contains}`"
    exit 1
  end
  puts
end

def encrypt(key, message)
  c = OpenSSL::Cipher.new("aes-256-cbc")
  c.encrypt
  iv = c.random_iv
  c.key = sha256_bin(key)
  Base64.urlsafe_encode64(iv + c.update(message.ljust(256)) + c.final)
end

def erb(template, params: {})
  template = File.read(template)
  ERB.new(template).result(binding)
end

class Dockerfile
  def initialize
    @lines = _prelude
    @targets = []
  end

  def _prelude = [
    "FROM #{IMAGES[:go]} AS entrypoint",
    "WORKDIR /app",
    "COPY logo.txt entrypoint.go go.mod go.sum .",
    "RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 go build -o /entrypoint entrypoint.go",
  ]

  def from(image, as:)
    runtime_target = as && !as["build"]
    raise "Dockerfile#from: no image set" if image.empty?
    line = "FROM #{image}"
    line += " AS #{as}" if as
    @targets << as if runtime_target
    @lines << ""
    @lines << line
    if runtime_target
      @lines << "COPY --from=entrypoint /entrypoint /entrypoint"
      @lines << "ENV TERM=xterm-256color"
      @lines << 'ENTRYPOINT ["/entrypoint"]'
    end
    self
  end

  def env(name, value)
    @lines << "ENV #{name}=#{Shellwords.shellescape(value)}"
  end

  def run(command, mounts: [])
    prefix = ""
    unless mounts.empty?
      prefix = mounts.map{"--mount=#{it}"}.join(' ') + " "
    end
    @lines << "RUN #{prefix}#{command}"
    self
  end

  def command(command)
    if command.is_a?(Array)
      @lines << "CMD #{command.map(&:to_s).inspect}"
    else
      @lines << "CMD #{command}"
    end
    self
  end

  def entrypoint(command)
    if command.is_a?(Array)
      @lines << "ENTRYPOINT #{command.map(&:to_s).inspect}"
    else
      @lines << "ENTRYPOINT #{command}"
    end
    self
  end

  def copy(file, to)
    @lines << "COPY #{file} #{to}"
    self
  end

  def to_s
    @lines.join("\n")
  end

  def build!(tag: TAG, solutions: [])
    dockerfile = "Dockerfile.#{tag}"
    args = "--platform=linux/amd64 -f #{dockerfile}"

    File.write(dockerfile, to_s)
    @targets.each do |target|
      system("docker build #{args} --target=#{target} -t #{tag}:#{target} .")
    end

    File.write("#{tag}.solutions.json", {solutions:}.to_json)
  end
end
