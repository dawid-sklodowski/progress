class AppScaffold
  class RouteAlreadyDefined < StandardError;end
  class UnknownRoute< StandardError;end

  def self.get(path, &block)
    store_route('GET', path, &block)
  end

  def self.post(path, &block)
    store_route('POST', path, &block)
  end

  def self.make_routes_for_public_files
    Dir.entries('public').select{|entry| !File.directory?("public/#{entry}")}.
                          collect{|entry| "/#{entry}"}.each do |entry|
      get entry do |request, response|
        response.format = File.extname(entry).sub(/^\./, '')
        File.open("public/#{entry}").read
      end
    end
  end

  def self.routes
    @routes
  end

  def initialize(request)
    @request = request
  end

  def process
    unless routes && routes[@request.type] && routes[@request.type][@request.path]
      raise AppScaffold::UnknownRoute
    end
    @response = HttpResponse.new(@request)
    @response.content ||= routes[@request.type][@request.path].call(@request, @response)
    @response.process
  end

  def routes
    self.class.routes
  end

  private
  def self.store_route(type, path, &block)
    @routes ||= {}
    @routes[type] ||= {}
    raise RouteAlreadyDefined if @routes[type][path]
    @routes[type][path] = block
  end

  def self.haml(template, locals={})
    engine = ::Haml::Engine.new(File.read("views/#{template.to_s}.haml"))
    engine.render(Object.new, locals)
  end
end