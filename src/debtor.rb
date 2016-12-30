require 'virtus'
require_relative 'collection'

class Debtor
  include Virtus.model

  EPSILON = 1.0e-3

  attribute :name, String
  attribute :owed, BigDecimal
  attribute :payments, Collection

  def receive_payment(payment)
    raise ArgumentError unless can_accept? payment

    @owed -= payment.amount
    @payments.push payment
  end

  def can_accept?(payment)
    payment.amount <= owed
  end

  def paid_in_full?
    owed < EPSILON
  end
end
