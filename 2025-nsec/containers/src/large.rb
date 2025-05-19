flag = "FLAG-822cf98e330afe10b01cd97c07b2b69a948f9b1899fee9c518d5c0eb9a6c4d91a"
n = flag.size / 2
flag_parts = chunk(flag, n)

secret = SecureRandom.hex(n*16)
secret_parts = chunk(secret, n)

d = Dockerfile.new

def random_path
  p = SecureRandom.urlsafe_base64(32)
  p.chars.each.with_index do |c, i|
    next if i == 0 || i == p.size - 1
    p[i] = '/' if rand < 0.2
  end
  p.gsub!(/\/+/, '/')
end

def random_lib
  "lib#{SecureRandom.hex(2)}"
end

secret_parts.each.with_index do |solution, i|
  message = "Congrats, you found part #{i + 1} of the flag! Here it is: #{flag_parts[i]}\n"
  paths = 10.times.map { random_path }
  checksums = paths.map {|p| SecureRandom.hex(2) }
  checksums.pop # remove last element

  lib_name = random_lib
  xor_a = rand(0..65536)
  xor_b =  rand(0..65536)

  offset = solution.bytes.map { rand(10..250) }

  build_tag = "build_p#{i + 1}"
  d.from(IMAGES[:bun], as: build_tag)
  d.run("apt-get update && apt-get install build-essential -y")
  "tmp/#{hmac(flag, "large_bun_lib#{i}")}.c".tap do |name|
    File.write(name, erb("templates/largevm.c", params: {
      checksum: checksums.join,
      solution: solution,
      offset: offset,
    }))
    d.copy(name, "large.c")
  end
  d.run("gcc -c -fPIC -DXA=#{xor_a} -DXB=#{xor_b} large.c -o large.o")
  d.run("gcc -shared large.o -o /#{lib_name}.so")

  js_build_tag = "build_js_p#{i + 1}"
  d.from(IMAGES[:bun], as: js_build_tag)
  js_path = random_path
  "tmp/#{hmac(flag, "large_bun#{i}")}".tap do |name|
    File.write(name, erb("templates/large.ts", params: {
      checksum: checksums.join,
      solution: solution,
      offset: offset,
      xor_a:, xor_b:,
    }))
    d.copy(name, "/src.ts")
    d.run("bun build --minify --target=bun /src.ts --outfile /#{js_path}")
  end

  # runtime image
  d.from(IMAGES[:bun], as: "p#{i + 1}")

  list = (paths + (127.times).map{random_path}).shuffle
  list_path = random_path
  tmp_l = "tmp/l#{i}"
  File.write(tmp_l, list.join("\n"))
  d.copy(tmp_l, "/#{list_path}")
  d.env("LP", list_path)

  d.copy("--from=#{js_build_tag} /#{js_path}", "/#{js_path}")

  j = i # pain
  paths.each.with_index do |p, i|
    out = if i == paths.size - 1
      erb("templates/large_entrypoint.sh", params: {
        checksum: checksums.join,
        bun: "/#{js_path}",
        lib: lib_name,
      })
    else
      if i == 0
        d.env("E", "sh /#{p}")

        # entrypoint command
        d.command(["sh", "/#{p}"])
      end

      erb("templates/large_redirect.sh", params: {
        next: "/" + paths[i + 1],
        index: list.index(paths[i + 1]) + 1,
        checksum: checksums[i],
        list_path: list_path,
      })
    end

    name = "tmp/#{hmac(flag, "large_sh_#{j}_#{i}")}"
    File.write(name, out)
    d.copy(name, "/#{p}")
  end

  d.env("ENC", encrypt(solution, message))
  d.copy("--from=#{build_tag} /#{lib_name}.so", "/usr/lib/x86_64-linux-gnu/#{lib_name}.so")
end

d.build!(solutions: secret_parts)

puts "solutions:"
puts secret_parts.inspect

if ENV["TEST"]
  test_container(solutions: secret_parts)
end
