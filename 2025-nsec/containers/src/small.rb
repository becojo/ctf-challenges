n = 3
flag = "FLAG-6b44cae75180580cb18e643e57c8a9cafc1c3e1f"
flag_parts = chunk(flag, n)

secret = SecureRandom.hex(n*16)
secret_parts = chunk(secret, n)

d = Dockerfile.new

secret_parts.each.with_index do |solution, i|
  name = "sx#{i}.rb"
  xor = rand(2**32)
  out = erb("templates/xor.rb", params: {
    solution:, xor:,
  })

  out_b64 = Base64.urlsafe_encode64(out)
  out = "require 'base64'\neval(Base64.urlsafe_decode64(#{out_b64.bytes.inspect}.map(&:chr).join))"
  out += "\n__END__\n"
  out += solution.bytes.map{it^xor}.join(' ')

  message = "Congrats, you found part #{i + 1} of the flag! Here it is: #{flag_parts[i]}\n"

  File.write("tmp/#{name}", out)

  r = rand(2**32).to_s

  d.from(IMAGES[:ruby], as: "p#{i + 1}")
  d.env("ENC", encrypt(solution, message))
  d.copy("tmp/#{name}", "/#{r}")
  d.command(["ruby", "/#{r}"])
end

d.build!(solutions: secret_parts)

puts "solutions:"
puts secret_parts.inspect


if ENV["TEST"]
  test_container(solutions: secret_parts)
end