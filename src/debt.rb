require 'virtus'
require_relative 'spender'

class Debt
  include Virtus.model

  attribute :amount, BigDecimal
  attribute :creditor, Spender
end
