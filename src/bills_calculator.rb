require_relative 'debt'
require_relative 'collection'
require_relative 'debtor'
require_relative 'debtee'

class BillsCalculator
  attr_reader :spenders, :expenses, :debtors, :debtees

  def initialize(expenses)
    @expenses = expenses
    populate
  end

  def total_people
    @spenders.sum :members
  end

  def total
    @expenses.sum :amount
  end

  def split
    total / total_people
  end

  def create_debtor_and_debtee_collections
    # https://stackoverflow.com/questions/3371518
    # largest debt holder first
    @debtors = @spenders.filter_map(:debtor?, :to_debtor)
    # largest debt first
    @debtees = @spenders.filter_map(:debtee?, :to_debtee).reverse!
  end

  def sort_by_amount_owed!
    @spenders.each do |spender|
      spender.calc_amount_owed(split)
    end

    # sorts to to high
    @spenders.sort_by!(&:amount_owed)
  end

  def calculate!
    sort_by_amount_owed!
    create_debtor_and_debtee_collections

    debtees.each do |d|
      new_debt = Debt.new(amount: d.debt, debtor: debtors.last)
      d.update_debts new_debt
    end
  end

  def debts_balanced?
    debtees.sum(:debts_total) == debtors.sum(:owed)
  end

  private

  def populate
    add_spenders
    map_expenses
  end

  def add_spenders
    @spenders = @expenses
                .uniques(:spender)
                .collect(&Spender.method(:new))
                .to_collection
  end

  def map_expenses
    @spenders.each do |spender|
      @expenses
        .select { |expense| expense.spender == spender.name }
        .each(&spender.method(:add_expense))
    end
  end
end
