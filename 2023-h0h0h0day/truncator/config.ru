#!/usr/bin/env ruby

require_relative 'app'

module Kernel
  def exit!
    raise "pls don't kill the challenge thank u"
  end

  def exec(*)
    raise "using Kernel.exec will kill the challenge pls dont thank u"
  end

  def system(*)
    raise "system: try something else there are no executables in this container"
  end
end

run Sinatra::Application
