require_relative 'debt'
require_relative 'collection'
require_relative 'debtor'
require_relative 'debtee'

class BillsCalculator
  attr_reader :spenders, :expenses, :debtors, :debtees

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

  def calculate_amounts_owed
    @spenders.each do |spender|
      spender.calc_amount_owed(split)
    end

    # sorts low to to high
    @spenders.sort_by!(&:amount_owed)
  end

  def prepare_expenses
    calculate_amounts_owed
    # https://stackoverflow.com/questions/3371518
    @debtors = spenders.filter_map(:debtor?, :to_debtor)
    # sort largest debt first
    @debtees = spenders.filter_map(:debtee?, :to_debtee).sort_by!(&:debt)
  end

  def balance_debts
    prepare_expenses

    debtees.each do |debtee|
      while debtee.owes_money?
        # sort debtors for largest owed
        debtor = debtors.sort_by!(&:owed).reverse!.first
        payment = Payment.new(to: debtor)
        payment.calc_amount(debtee.debt)
        debtee.make_payment(payment)
      end
    end
  end

  def debts_paid_equals_debts_owed?
    debtees.sum(:debts_total) == debtors.sum(:owed)
  end

  def everybody_balanced?
    debtees.all?(&:debts_paid?) && debtors.all?(&:paid_in_full?)
  end

  def debts_balanced?
    # these methods call methods on potential nil values
    everybody_balanced? && debts_paid_equals_debts_owed?
  rescue
    false
  end

  def payments
    if debts_balanced?
      debtees.map(&:payments).flatten
    else
      balance_debts
      payments
    end
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
