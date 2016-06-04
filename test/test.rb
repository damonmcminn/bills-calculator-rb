require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!
Dir['./src/*.rb'].each { |file| require file }

class BillsCalculatorTests < MiniTest::Test
  def test_spender_counts_members_correctly
    assert_equal Spender.new('Tom, Dick & Harry').members, 3
    assert_equal Spender.new('Jane').members, 1
    assert_equal Spender.new('Jack and Jill').members, 2
    assert_equal Spender.new('Julian&Dick,Anne,George and Timmy The Dog').members, 5
    assert_equal Spender.new('Joyce Banda and Amanda').members, 2
  end

  def test_spender_calc_amount_owed
    one_member = Spender.new('Daisy')
    four_members = Spender.new('Alpha, Beta, Charlie & Delta')

    one_member.stub :total_spend, 10 do
      one_member.calc_amount_owed(15)
      assert_equal one_member.amount_owed, 5
    end

    four_members.stub :total_spend, 10 do
      four_members.calc_amount_owed(5)
      assert_equal four_members.amount_owed, 10
    end
  end

  def test_string_snake_case
    assert_equal 'SOMETHING Something DarkSide'.snake_case, 'something_something_darkside'
  end

  def test_collection_sum
    coll = Collection.new([1, 2, 3, 4])
    assert_equal coll.sum(:abs), 10
  end

  def test_collection_filter_map
    coll = Collection.new([1, 2, 3]).filter_map(:even?, :to_f)
    assert_equal coll.class, Collection
    assert_equal coll.size, 1
    assert_equal coll.first, 2.0
    assert_equal coll.first.class, Float
  end

  def test_debtee_make_payment
    debtee = Debtee.new(debt: 100)
    p = Payment.new(amount: 100, to: Debtor.new)
    payment = MiniTest::Mock.new(p)
    payment.expect :submit!, nil

    debtee.make_payment(payment)
    payment.verify
    assert debtee.debt.zero?
    assert_equal debtee.payments.sum(:amount), 100
    assert_raises { debtee.make_payment(payment) }
  end

  def test_debtor_receive_payment
    debtor = Debtor.new(owed: 1)
    payment = Payment.new(amount: 1)
    debtor.receive_payment(payment)

    assert debtor.owed.zero?, 'Receiving payment should reduce :owed'
    assert_equal debtor.payments.first, payment
    assert_raises { debtor.receive_payment(payment) }
  end

  def test_payment_submit!
    to = MiniTest::Mock.new(Debtor.new)
    payment = Payment.new(to: to)
    to.expect :receive_payment, nil, [payment]

    payment.submit!
    to.verify
  end

  def test_debtor_paid_in_full?
    debtor = Debtor.new(owed: 1)
    debtor.receive_payment(Payment.new(amount: 1))

    assert debtor.paid_in_full?
  end

  def test_debtee_debts_paid?
    debtee = Debtee.new(debt: 0)

    assert debtee.debts_paid?
  end

  def test_debtee_owes_money?
    debtee = Debtee.new(debt: 1)

    assert debtee.owes_money?
  end

  def bills_calculator_balance_debts(expenses)
    calc = BillsCalculator.new(expenses)
    calc.balance_debts
    assert calc.debts_balanced?
    # return self for further assertions
    calc
  end

  def test_one_debtee_one_debtor
    expenses = [
      Expense.new(spender: 'a', amount: 2),
      Expense.new(spender: 'b', amount: 0)
    ]
    bills_calculator_balance_debts expenses
  end

  def test_two_debtors_one_debtee
    expenses = [
      Expense.new(spender: 'a', amount: 6),
      Expense.new(spender: 'b', amount: 6),
      Expense.new(spender: 'c', amount: 0)
    ]
    bills_calculator_balance_debts expenses
  end

  def test_two_debtors_two_debtees
    expenses = [
      Expense.new(spender: 'a & d', amount: 12.34),
      Expense.new(spender: 'b', amount: 0),
      Expense.new(spender: 'c', amount: 0)
    ]
    bills_calculator_balance_debts expenses
  end

  def test_bills_calculator_payments
    expenses = [
      Expense.new(spender: 'a', amount: 10),
      Expense.new(spender: 'b', amount: 0),
      Expense.new(spender: 'c', amount: 0),
      Expense.new(spender: 'd', amount: 0),
      Expense.new(spender: 'e', amount: 0)
    ]
    calc = BillsCalculator.new(expenses)

    assert_equal calc.payments.size, 4
  end

  def test_bigdecimal_to_money
    assert_equal '1.00', BigDecimal.new(1).to_money
    assert_equal '1.11', BigDecimal.new(1.11, 3).to_money
  end
end
