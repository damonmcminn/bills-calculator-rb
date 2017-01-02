require 'sinatra'
require_relative 'azure_storage_table'

post_to_payload = -> {
  next unless request.post?

  request.body.rewind
  body = request.body.read

  @payload = body.empty? ? {} : JSON.parse(body)
}

cors_headers = -> {
  headers({
    'Access-Control-Allow-Origin' => '*',
    'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'OPTIONS']
  })
}

configuration = {
  before: [
    post_to_payload,
    cors_headers
  ],
  configure: [
    ->(*_) { set :server, :puma }
  ]
}

configuration.each do |method, xs|
  xs.each { |fn| self.send method, &fn }
end
