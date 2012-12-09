class HTTPRequest
  class BadRequest<::StandardError;end
  class CanProcessOnlyOnce<::StandardError;end
  attr_reader :request_id, :type, :uri, :headers, :raw_headers, :path, :params, :request_processing, :request_error
  BUFSIZE = 1024

  include MultipartParser

  @upload_requests = {}
  class << self
    attr_accessor :upload_requests
  end

  def self.new_request_id
    @@current_request_id = (defined? @@current_request_id) ? @@current_request_id+1 : 1
  end

  def initialize(socket)
    @socket = socket
    @request_id = self.class.new_request_id
  end

  def process
    raise CanProcessOnlyOnce if @processed
    @processed=true
    Thread.start do
      process_without_thread
    end
  end

  def body
    @body ||= save_request_body
  end

  def progress
    return {:state=>'error'} if @request_error || !@total_data
    if @remaining_data > 0
      state = 'uploading'
    else
      if @request_processing
        state = 'processing'
      else
        state = 'done'
      end
    end
    {:state=>state, :received=>@total_data - @remaining_data, :size=>@total_data}
  end

  def file_upload_path
    "tmp/upload-#{@request_id}#{uploads_count_suffix}"
  end

  def tmp_request_path
    "tmp/request-#{@request_id}"
  end

  def uploads_count_suffix
    if @uploads_count
      "-#{@upload_count += 1}"
    else
      @upload_count = 1
      nil
    end
  end

  private

  def process_without_thread
    begin
      @request_processing = true
      read_request_line
      read_headers
      read_params
      response = Application.new(self).process
      @socket.write response
      @request_processing = false
    rescue Exception=>e
      print "Error: #{e.message}\n"
      print e.backtrace.join("\n")
      @request_error = true
      raise e
    ensure
      @socket.close
      @body.close if @body
      File.unlink(@body.path) if @body
    end
  end

  def read_request_line
    @request_line = @socket.gets
    print @request_line
    raise BadRequest unless @request_line =~ /^(\S+)\s+(\S+)(?:\s+HTTP\/\d+\.\d+)?\r?\n/m
      @type = $1
      @uri  = URI.parse($2)
      @path = @uri.path.gsub(/\/+/,'/').sub(/(.)\/$/,'\1')
  end

  def read_headers
    @raw_headers = []
    @headers = {}
    while line = @socket.gets
      break if /\A(\r\n|\n)\z/m =~ line
      @raw_headers << line
    end
    @headers = Utilities.parse_headers(@raw_headers)
  end

  def read_params
    @params={}
    @params = Utilities.parse_query(@uri.query)
    return @params if @type == 'GET'
    self.class.upload_requests[@params['upload_id']] = self if @params['upload_id']
    if @headers['content-type'] =~ /^application\/x-www-form-urlencoded/
      @params.merge! Utilities.parse_query(body.read)
    elsif @headers['content-type'] =~ /^multipart\/form-data; boundary=(.+)/
      @boundary = Utilities.dequote($1)
      parse_multipart_form
    end
  end

  def save_request_body
    return nil unless @headers['content-length']
    @remaining_data ||= @total_data = @headers['content-length'].to_i
    file = File.open(tmp_request_path, 'wb+')
    while @remaining_data > 0
      size = BUFSIZE < @remaining_data ? BUFSIZE : @remaining_data
      break unless chunk = @socket.read(size)
      @remaining_data -= chunk.size
      file << chunk
    end
    raise BadRequest, "Invalid body size." if @remaining_data > 0 && @socket.eof?
    file.rewind && file
  end
end