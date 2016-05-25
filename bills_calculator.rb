class BillsCalculator
  attr_reader :spenders, :expenses
  attr_accessor :debtors, :debtees

  def initialize(expenses)
    @expenses = expenses
    populate
  end

  def total_people
    @spenders.map { |spender| spender.members }.inject(&:+)
  end

  def total
    @expenses.map(&:amount).reduce(&:+)
  end

  def split
    total / total_people
  end

  def add_debts
    @spenders.each do |spender|
      spender.add_debt(split)
    end

    # sorts to to high
    @spenders.sort_by!(&:debt)

    # largest debt holder first
    @debtors = @spenders.select(&:debtor?)
    # largest debt first
    @debtees = @spenders.select(&:debtee?).reverse!
  end

  def calculate
    add_debts

    debtees.each do |d|
      debtor = debtors.last
      d.update_debts(d.debt, debtor)
    end
  end

  def debts_balanced?
    # again, this is similiar to collection class thing...
    debtees.map(&:debts_total).reduce(&:+) == debtors.map(&:owed).reduce(&:+)
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
  end

  def map_expenses
    @spenders.each do |spender|
      @expenses
        .select { |expense| expense.spender == spender.name }
        .each &spender.method(:add_expense)
    end
  end
end
