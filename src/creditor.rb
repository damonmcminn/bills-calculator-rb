require 'virtus'
require_relative 'collection'

class Creditor
  include Virtus.model

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
    owed.essentially_zero?
  end
end
