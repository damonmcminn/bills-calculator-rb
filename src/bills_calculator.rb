require_relative 'debt'
require_relative 'collection'
require_relative 'creditor'
require_relative 'debtor'
require_relative 'payment'
require_relative 'result'

class BillsCalculator
  attr_reader :spenders, :expenses, :creditors

  def initialize(expenses)
    @expenses = Collection.new(expenses)
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

  def calculate_amounts_owed!
    @spenders.each do |spender|
      spender.calc_amount_owed(split)
    end

    # sorts low to to high
    @spenders.sort_by!(&:amount_owed)
  end

  def creditors
    # https://stackoverflow.com/questions/3371518
    @creditors ||= spenders.filter_map(:creditor?, :to_creditor)
  end

  def debtors
    # sort largest debt first
    @debtors ||= spenders.filter_map(:debtor?, :to_debtor).sort_by!(&:debt)
  end

  def balance_debts!
    calculate_amounts_owed!

    debtors.each do |debtor|
      while debtor.owes_money?
        # sort creditors for largest owed
        creditor = creditors.sort_by!(&:owed).reverse!.first
        payment = Payment.new(to: creditor)
        payment.calc_amount(debtor.debt)
        debtor.make_payment(payment)
      end
    end
  end

  def everything_zeroed?
    difference = (creditors.sum(:owed) - debtors.sum(:debts_total))
    difference.essentially_zero?
  end

  def everybody_balanced?
    debtors.all?(&:debts_paid?) && creditors.all?(&:paid_in_full?)
  end

  def debts_balanced?
    # these methods call methods on potential nil values
    everybody_balanced? && everything_zeroed?
  rescue
    false
  end

  def payments
    if debts_balanced?
      debtors.map(&:payments).flatten
    else
      balance_debts!
      payments
    end
  end

  def result
    Result.new(payments, spenders, expenses)
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
