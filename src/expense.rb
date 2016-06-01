require 'bigdecimal'
require 'virtus'

class Expense
  include Virtus.model

  attribute :spender
  attribute :amount, BigDecimal
  attribute :description, String
  attribute :dates, String
end
