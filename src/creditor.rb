class Creditor
  attr_reader :name, :owed, :payments

  def initialize(name: '', owed: 0, payments: [])
    @name = name
    @owed = owed
    @payments = payments
  end

  def receive_payment(payment)
    raise ArgumentError unless can_accept? payment

    @owed -= payment.amount
    @payments.push payment
  end

  def can_accept?(payment)
    payment.amount <= owed
  end

  def paid_in_full?
    owed.essentially_zero?
  end
end
