require 'csv'

require './spender'
require './expense'
require './lib'
require './bills_calculator'

# data = CSV.hashify('bills.csv').map(&Expense.method(:new))
data = CSV.hashify('bills.csv').map { |bill| Expense.new(bill) }
calc = BillsCalculator.new(data)

require 'pry'
Pry.start(binding)
