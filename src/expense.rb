require 'bigdecimal'
require 'virtus'

class Expense
  include Virtus.model

  attribute :spender
  attribute :amount, BigDecimal
  attribute :description, String
  attribute :date_start, Date
  attribute :date_end, Date
end
