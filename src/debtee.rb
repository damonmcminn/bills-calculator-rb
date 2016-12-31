require 'virtus'
require_relative 'collection'

class Debtee
  include Virtus.model

  attribute :name, String
  attribute :debts, Collection
  attribute :payments, Collection
  attribute :debt, BigDecimal

  def update_debts(new_debt)
    debts.push new_debt
  end

  def debts_total
    debts.sum :amount
  end

  def make_payment(payment)
    payment.from = self
    payment.submit!
    reduce_debt_by payment.amount
    payments.push payment
  end

  def debts_paid?
    debt.essentially_zero?
  end

  def owes_money?
    !debts_paid?
  end

  private

  def reduce_debt_by(amount)
    if amount > debt
      raise ArgumentError, 'Can\'t pay more than the debt'
    else
      @debt -= amount
    end
  end
end
