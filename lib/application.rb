class Application < AppScaffold
  make_routes_for_public_files
  get '/' do |request, response|
    haml :index, :upload_id=>request.request_id
  end

  post '/file' do |request, response|
    request.params['file']
  end

  post '/save' do |request, response|
    if request.params['title'] && request.params['path']
      "Title: #{request.params['title']}, Path: #{request.params['path']}"
    end
  end

  get '/progress' do |request, response|
    response.format = :json
    if upload_id = request.params['upload_id']
      if HTTPRequest.upload_requests[upload_id]
        HTTPRequest.upload_requests[upload_id].progress.to_json
      else
        {:state=>'error'}.to_json
      end
    end
  end
end