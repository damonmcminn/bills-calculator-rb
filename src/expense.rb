require 'bigdecimal'

class Expense
  attr_reader :amount, :spender, :description, :dates

  def initialize(spender:, amount:, description: nil, dates: nil)
    @spender = spender
    @description = description
    @dates = dates
    @amount = Expense.sanitized_decimal(amount)
  end

  def self.sanitized_decimal(amount)
    sanitized = /\d+\.?\d{0,2}/.match(amount.to_s)[0]

    BigDecimal(sanitized)
  end
end
