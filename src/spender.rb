require_relative 'collection'
require_relative 'creditor'

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

  def to_creditor
    Creditor.new(name: name, owed: amount_owed.abs)
  end

  def to_debtor
    Debtor.new(name: name, debt: amount_owed)
  end

  def share
    @split * members
  end

  # how amount_owed is calculated is the root of the problem
  # tested with .NET (F#) also
  # in the case of the creditor, share is less than total_spend
  # this results in a negative value, but one that is FRACTIONALLY different than total_spend - (share * num_debtors)
  # eg by 1.0e-18, which is less than Float::EPSILON

  # poorly named
  # this means how much does the spender owe
  def amount_owed
    share - total_spend
  end

  def calc_amount_owed(split)
    @split = split
    amount_owed
  end

  def creditor?
    amount_owed < 0
  end

  def debtor?
    !creditor?
  end
end
