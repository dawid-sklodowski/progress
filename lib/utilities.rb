module Utilities
  def self.parse_query(str)
    query = {}
    if str
      str.split(/[&;]/).each do |x|
        next if x.empty?
        key, val = x.split(/=/,2).map{|el| CGI.unescape(el)}
        query[key] = val
      end
    end
    query
  end

  def self.parse_headers(raw)
    header = {}
    field = nil
    raw.each{|line|
      case line
        when /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):\s*(.*?)\s*\z/m
          field, value = $1, $2
          field.downcase!
          header[field] = value
        when /^\s+(.*?)\s*\z/m
          value = $1
          unless field
            raise HTTPRequest::BadRequest, "bad header '#{line.inspect}'."
          end
          header[field] << " " << value
        else
          raise HTTPRequest::BadRequest, "bad header '#{line.inspect}'."
      end
    }
    header.each{|key, value|
     value.strip!
     value.gsub!(/\s+/, " ")
    }
    header
  end

  def self.dequote(str)
    ret = (/\A"(.*)"\Z/ =~ str) ? $1 : str.dup
    ret.gsub!(/\\(.)/, "\\1")
    ret
  end
end
