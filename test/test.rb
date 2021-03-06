require 'minitest/autorun'
require 'minitest/reporters'
require 'timeout'

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

  def test_array_sum
    xs = [1, 2, 3, 4]
    assert_equal xs.sum(:abs), 10
  end

  def test_array_sum_handles_nil_values_as_zero
    xs = [nil, 1, 2, 3, 4]
    assert_equal xs.sum(:abs), 10
  end

  def test_array_filter_map
    xs = [1, 2, 3].filter_map(:even?, :to_f)
    assert_equal xs.class, Array
    assert_equal xs.size, 1
    assert_equal xs.first, 2.0
    assert_equal xs.first.class, Float
  end

  def test_debtor_make_payment
    debtor = Debtor.new(debt: 100)
    p = Payment.new(amount: 100, to: Creditor.new)
    payment = MiniTest::Mock.new(p)
    payment.expect :submit!, nil

    debtor.make_payment(payment)
    payment.verify
    assert debtor.debt.zero?
    assert_equal debtor.payments.sum(:amount), 100
    assert_raises { debtor.make_payment(payment) }
  end

  def test_creditor_receive_payment
    creditor = Creditor.new(owed: 1)
    payment = Payment.new(amount: 1)
    creditor.receive_payment(payment)

    assert creditor.owed.zero?, 'Receiving payment should reduce :owed'
    assert_equal creditor.payments.first, payment
    assert_raises { creditor.receive_payment(payment) }
  end

  def test_payment_submit!
    to = MiniTest::Mock.new(Creditor.new)
    payment = Payment.new(to: to)
    to.expect :receive_payment, nil, [payment]

    payment.submit!
    to.verify
  end

  def test_creditor_paid_in_full?
    creditor = Creditor.new(owed: 1)
    creditor.receive_payment(Payment.new(amount: 1))

    assert creditor.paid_in_full?
  end

  def test_debtor_debts_paid?
    debtor = Debtor.new(debt: 0)

    assert debtor.debts_paid?
  end

  def test_debtor_owes_money?
    debtor = Debtor.new(debt: 1)

    assert debtor.owes_money?
  end

  def bills_calculator_balance_debts!(expenses)
    calc = BillsCalculator.new(expenses)
    calc.balance_debts!
    assert calc.debts_balanced?
    # return self for further assertions
    calc
  end

  def test_one_debtor_one_creditor
    expenses = [
      Expense.new(spender: 'a', amount: 2),
      Expense.new(spender: 'b', amount: 0)
    ]
    bills_calculator_balance_debts! expenses
  end

  def test_two_creditors_one_debtor
    expenses = [
      Expense.new(spender: 'a', amount: 6),
      Expense.new(spender: 'b', amount: 6),
      Expense.new(spender: 'c', amount: 0)
    ]
    bills_calculator_balance_debts! expenses
  end

  def test_two_creditors_two_debtors
    expenses = [
      Expense.new(spender: 'a & d', amount: 12.34),
      Expense.new(spender: 'b', amount: 0),
      Expense.new(spender: 'c', amount: 0)
    ]
    bills_calculator_balance_debts! expenses
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

  def test_numeric_to_money
    assert_equal '1.00', BigDecimal(1).to_money
    assert_equal '1.11', BigDecimal(1.11, 3).to_money
    assert_equal '1.00', 1.to_money
    assert_equal '1.24', 1.239.to_money
  end

  def test_bills_calculator_result
    bills = [
      Expense.new(spender: 'a', amount: 1, description: 'foo', dates: 'foo'),
      Expense.new(spender: 'a', amount: 2, description: 'bar', dates: 'bar'),
      Expense.new(spender: 'b', amount: 0),
      Expense.new(spender: 'c', amount: 0)
    ]

    result = BillsCalculator.new(bills).result
    payments = result.payments
    spenders = result.spenders
    expenses = result.expenses

    assert_equal '1.00', payments.first.amount
    assert_equal 'c', payments.last.from
    assert_equal 'a', spenders.first.name
    assert_equal '0.00', spenders.first.owes
    assert_equal '1.00', spenders.last.share
    assert_equal '3.00', spenders.first.total_spend
    assert_equal 2, expenses.size
    assert_equal 'foo', expenses.first.description
    assert_equal '2.00', expenses.last.total
    assert_equal 'bar', expenses.last.dates
  end

  def test_calculating_doesnt_cause_infinite_recursion
    _115 = [Expense.new(spender: 'a', amount: 115, description: 'a failing test')]
    _116 = [Expense.new(spender: 'a', amount: 116, description: 'a failing test')]

    no_spend = [
      Expense.new(spender: 'b', amount: 0),
      Expense.new(spender: 'c', amount: 0)
    ]

    Timeout::timeout(1) { BillsCalculator.new(_115).result }
    Timeout::timeout(1) { BillsCalculator.new(no_spend).result }
    Timeout::timeout(1) { BillsCalculator.new(no_spend + _116).result }
    Timeout::timeout(1) { BillsCalculator.new( _116).result }
    Timeout::timeout(1) { BillsCalculator.new(no_spend + _115).result }
  end
end
