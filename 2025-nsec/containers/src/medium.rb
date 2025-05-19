n = 10
flag = "FLAG-d2a240d053e4814c54c74389eefbdb945z4cfe0b71b6249ce8a35307248991d86"
flag_parts = chunk(flag, n)

secret = SecureRandom.hex(n*16)
secret_parts = chunk(secret, n)

d = Dockerfile.new

secret_parts.each.with_index do |solution, i|
    name = "mx#{i}.go"
    xor = (rand * 1024).to_i
    xor2 = (rand * 1024).to_i
    out = erb("templates/map.go", params: {
        solution:, xor:, xor2:
    })

    message = "Congrats, you found part #{i + 1} of the flag! Here it is: #{flag_parts[i]}\n"

    File.write("tmp/#{name}", out)

    d.from(IMAGES[:go], as: "p#{i + 1}")
    d.copy("tmp/#{name}", "/#{name}")
    d.run("go build -ldflags=\"-X 'main.pff=#{xor2}'\" -o /o /#{name}", mounts: [
        "type=cache,target=/root/.cache/go-build",
        "type=tmpfs,target=/root/.config/go"
    ])
    d.run("rm /#{name}") # "hide" the source code
    d.env("ENC", encrypt(solution, message))
    d.env("X", xor)
    d.command(["/o"])
end

d.build!(solutions: secret_parts)

puts "solutions:"
puts secret_parts.inspect

if ENV["TEST"]
    test_container(solutions: secret_parts)
end
