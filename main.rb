require 'csv'
require 'trollop'
require 'pry'

# monkeypatches et al
require_relative 'src/lib'
require_relative 'src/expense'
require_relative 'src/bills_calculator'

opts = Trollop.options do
  opt :file, 'CSV file', type: String
end

Trollop.die 'Need to specify a CSV file' unless opts[:file]

# data = CSV.hashify(opts[:file]).map(&Expense.method(:new))
# expenses = data.to_collection

# tap is for side-effect calls that don't return self
# so self can be chained...
# https://blog.engineyard.com/2015/five-ruby-methods-you-should-be-using#object-tap
# result = BillsCalculator.new(expenses).tap(&:calculate!)

Trollop.die 'Not implemented yet'
