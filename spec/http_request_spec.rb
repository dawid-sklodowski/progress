require 'spec_helper'
require 'progress2'
require 'stringio'

describe HTTPRequest do
  describe 'new' do
    it 'initializes new objects with increasing uuid' do
      server1 = HTTPRequest.new(nil)
      server2 = HTTPRequest.new(nil)
      server2.request_id.should == server1.request_id + 1
    end
  end

  describe '#read_request_line' do
    it 'works' do
      request = HTTPRequest.new(StringIO.new("POST /save?something=asd HTTP/1.1\r\n"))
      request.send(:read_request_line)
      request.type.should == 'POST'
      request.path.should == '/save'
    end
  end

  describe '#read_headers' do
    it 'works' do
      request = HTTPRequest.new(File.open('spec/headers1', 'r'))
      expected = {"host"=>"localhost:2000", "user-agent"=>"Mozilla/5.0 (X11; Linux i686; rv:10.0.1) Gecko/20100101 Firefox/10.0.1", "accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "accept-language"=>"en-us,en;q=0.5", "accept-encoding"=>"gzip, deflate", "connection"=>"keep-alive", "cache-control"=>"max-age=0"}
      request.send(:read_headers).should == expected
    end
  end

  describe 'processing requests' do
    describe 'GET /progress.js' do
      it 'works' do
        io = StringIO.new(File.open('spec/get-request1', 'r').read)
        request = HTTPRequest.new(io)
        request.send(:process_without_thread)
        request.path.should == '/progress.js'
        request.body.should == nil
      end
    end

    describe 'POST non-multipart' do
      it 'works' do
        io = StringIO.new(File.open('spec/post-nonmultipart-request', 'r').read)
        request = HTTPRequest.new(io)
        request.send(:process_without_thread)
        request.path.should == '/save'
      end
    end

    describe 'POST multipart' do
      it 'works' do
        io = StringIO.new(File.open('spec/post-multipart-request', 'r').read)
        request = HTTPRequest.new(io)
        request.send(:process_without_thread)
        request.path.should == '/file'
        request.params['file'].should be_an_instance_of(String)
        saved = File.open(request.params['file'], 'r') do |file|
          file.read
        end
        original =  File.open('spec/yakuakerc', 'r') do |file|
          file.read
        end
        saved.should == original
      end
    end
  end
end