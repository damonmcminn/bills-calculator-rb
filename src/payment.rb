require 'virtus'
require_relative 'debtee'
require_relative 'debtor'

class Payment
  include Virtus.model

  attribute :from, Debtee
  attribute :to, Debtor
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
