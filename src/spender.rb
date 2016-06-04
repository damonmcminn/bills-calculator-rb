require_relative 'collection'
require_relative 'debtor'

class Spender
  attr_reader :name, :expenses, :amount_owed

  def initialize(name)
    @name = name
    @expenses = Collection.new
  end

  def members
    name.split(/&|,| and |\+/).size
  end

  def add_expense(expense)
    @expenses.push expense
  end

  def total_spend
    expenses.sum :amount
  end

  def to_debtor
    Debtor.new(name: name, owed: amount_owed.abs)
  end

  def to_debtee
    Debtee.new(name: name, debt: amount_owed)
  end

  def share
    @split * members
  end

  def amount_owed
    share - total_spend
  end

  def calc_amount_owed(split)
    @split = split
    amount_owed
  end

  def debtor?
    amount_owed < 0
  end

  def debtee?
    !debtor?
  end
end
