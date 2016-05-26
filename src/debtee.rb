require 'virtus'
require_relative 'collection'

class Debtee
  include Virtus.model

  attribute :name, String
  attribute :debts, Collection
  attribute :debt, BigDecimal

  def update_debts(new_debt)
    debts.push new_debt
  end

  def debts_total
    debts.sum :amount
  end

  def debt_paid?
    (debt - debts_total).zero?
  end
end
