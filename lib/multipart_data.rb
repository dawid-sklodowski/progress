class MultipartData
  attr_accessor :name, :user_filename, :body
  def initialize(request)
    @request = request
    @headers = @file
    @body = ''
    @raw_headers = []
  end

  def <<(line)
    if @headers
      @body << @line_to_write if @line_to_write
      @line_to_write = line
    elsif line == "\r\n"
      @headers = Utilities::parse_headers(@raw_headers)
      if content_disposition = @headers['content-disposition']
        if content_disposition =~ /\s+name="(.*?)"/ then @name = $1 end
        if content_disposition =~ /\s+filename="(.*?)"/ then @user_filename = $1 end
        @body = @user_filename ? file_upload : ''
      end
    else
      @raw_headers << line
    end
  end

  def file_upload
    @file ||= File.open(@request.file_upload_path, 'wb+')
  end

  def finish!
    @body << @line_to_write.sub(/\r\n$/, '') if @line_to_write
    if @file
      @file.close
      #This is to my server running out of storage
      #File.unlink(@file.path)
    end
  end

  def value
    @file ? @file.path : @body
  end
end