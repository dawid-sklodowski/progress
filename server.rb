#!/usr/bin/env ruby
$: << File.expand_path(File.join(File.dirname(__FILE__), "lib"))
require 'progress'

#Thread.abort_on_exception = true
server  = TCPServer.open(2000)
loop do
  HTTPRequest.new(server.accept).process
end