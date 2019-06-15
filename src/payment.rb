require_relative 'debtor'
require_relative 'creditor'

class Payment
  attr_reader :to, :amount
  attr_accessor :from

  def initialize(from: Debtor.new, to: Creditor.new, amount: 0)
    @from = from
    @to = to
    @amount = amount
  end

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
