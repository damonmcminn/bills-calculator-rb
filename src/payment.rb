require 'virtus'
require_relative 'debtor'
require_relative 'creditor'

class Payment
  include Virtus.model

  attribute :from, Debtor
  attribute :to, Creditor
  attribute :amount, BigDecimal

  def submit!
    to.receive_payment self
  end

  def calc_amount(debt)
    @amount = if debt > to.owed
                to.owed
              else
                debt
              end
  end
end
