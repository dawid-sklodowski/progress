class HttpResponse
  class CannotProcessWithoutContent < StandardError;end

  attr_accessor :content, :format
  def initialize(request=nil)
    @headers = {'Server'=>'Progress2',
                'Date'=>Time.now.to_s,
                'Cache-Control'=>'max-age=0, private, no-store, no-cache, must-revalidate'}
    @request = request
  end

  def process
    @content ||=''
    @headers['Content-Type'] ||= self.class.content_type(@format)
    @headers['Content-Length'] = @content.length
    generate_headers + @content
  end

  def generate_headers
    (["HTTP/1.1 200 OK"] +
    @headers.collect{|key, value| "#{key}: #{value}"} +
    ["\r\n"]).join("\r\n")
  end

  def self.content_type(format=nil)
    return 'text/html'  if format == 'html' or format == 'htm'
    return 'text/plain' if format == 'txt'
    return 'text/css'   if format == 'css'
    return 'image/jpeg' if format == 'jpeg' or format == 'jpg'
    return 'image/gif'  if format == 'gif'
    return 'image/bmp'  if format == 'bmp'
    return 'text/plain' if format == 'rb'
    return 'text/xml'   if format == 'xml'
    return 'text/xml'   if format == 'xsl'
    return 'application/json' if format == 'json'
    return 'text/html'
  end
end