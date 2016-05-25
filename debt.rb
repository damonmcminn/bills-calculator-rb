require 'virtus'
require './spender'

class Debt
  include Virtus.model

  attribute :amount, BigDecimal
  attribute :debtor, Spender
end
