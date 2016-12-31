require 'json'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require_relative 'calculate_bills'

configure do
  set :server, :puma
end

before do
  # content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']

  request.body.rewind
  @payload = JSON.parse request.body.read
end

options '*' do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end

post '/calculate' do
  calculated = CalculateBills.run(@payload)

  if calculated.success?
    json calculated.result
  else
    status 400
    json outcome.errors.symbolic
  end
end