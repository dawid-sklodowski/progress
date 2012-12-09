require 'spec_helper'
require 'progress2'

describe HttpResponse do
  describe '#response' do
    it 'responds with headers and content' do
      response = HttpResponse.new
      response.content = 'something'
      response = response.process
      response.should =~ /^HTTP\/1\.1 200 OK\r\n.*Server: Progress2/m
      response.should =~ /something$/
    end
  end
end
