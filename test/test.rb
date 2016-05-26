require 'minitest/autorun'
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

  def test_debtee_debt_paid?
    debtee = Debtee.new(debt: 1_000_000)
    debtee.stub :debts_total, 1_000_001 do
      refute debtee.debt_paid?
    end
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
end
