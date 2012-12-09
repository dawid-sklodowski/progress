module MultipartParser
  def parse_multipart_form
    @multipart_processing = true
    return unless body
    data=nil
    body.each_line do |line|
      if line =~ /\A--#{@boundary}(--)?\r\n\z/
        if data
          @params[data.name] = data.value
          data.finish!
        end
        data = MultipartData.new(self)
      else
        data << line if data
      end
    end
    @multipart_processing = false
  end
end