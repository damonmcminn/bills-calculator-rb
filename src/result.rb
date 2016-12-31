require 'json'

class Result
  def initialize(payments, spenders, expenses)
    @payments = payments
    @spenders = spenders
    @expenses = expenses
  end

  def payments
    _payments.map(&OpenStruct.method(:new))
  end

  def spenders
    _spenders.map(&OpenStruct.method(:new))
  end

  def expenses
    _expenses.map(&OpenStruct.method(:new))
  end

  def to_h
    {
      payments: _payments,
      spenders: _spenders,
      expenses: _expenses
    }
  end

  def to_json(options)
    to_h.to_json(options)
  end

  private

  def _payments
    @payments.map do |p|
      {
        from: p.from.name,
        to: p.to.name,
        amount: p.amount.to_money
      }
    end
  end

  def _spenders
    @spenders.map do |s|
      {
        name: s.name,
        owes: s.debtor? ? 0.to_money : s.amount_owed.to_money,
        share: s.share.to_money,
        total_spend: s.total_spend.to_money
      }
    end
  end

  def _expenses
    expense_types = @expenses.uniques(:description).reject(&:nil?)

    expense_types.map do |type|
      e = @expenses.select { |ex| ex.description == type }.to_collection
      {
        description: type,
        total: e.sum(:amount).to_money,
        dates: e.first.dates
      }
    end
  end
end