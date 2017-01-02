require 'json'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

require_relative 'calculate_bills'
require_relative 'api_configuration'
require_relative 'bills_storage'

post '/bills' do
  calculated = CalculateBills.run(@payload)

  if calculated.success?
    json calculated.result
  else
    status 400
    json calculated.errors.symbolic
  end
end

get '/bills/:row_id' do |row_id|
  bill = BillsStorage.find(row_id)

  status 404 if bill.nil?
  json bill
end