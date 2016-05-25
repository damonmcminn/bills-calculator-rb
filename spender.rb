class Spender
  attr_reader :name, :expenses, :debt

  def initialize(name)
    @name = name
    @expenses = []
    @debts = []
  end

  def members
    name.split(/&|,| and |\+/).size
  end

  def add_expense(expense)
    @expenses.push expense
  end

  def total_spend
    expenses.collect(&:amount).inject(&:+)
  end

  def add_debt(split)
    @debt = (split * members) - total_spend
  end

  def owed
    debtor? ? debt.abs : 0
  end

  def debtor?
    debt < 0
  end

  def debtee?
    !debtor?
  end

  def update_debts(new_debt)
    @debts.push new_debt
  end

  def debts_total
    # @debts.inject(BigDecimal.new(0)) { |total, d| total + d.amount }
    @debts.map(&:amount).reduce(&:+)
  end

  def debt_paid?
    (debt - debts_total).zero?
  end
end
