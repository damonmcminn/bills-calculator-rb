require_relative 'spender'
require 'virtus'

class Debtor
  include Virtus.model

  attribute :name, String
  attribute :owed, BigDecimal
end
