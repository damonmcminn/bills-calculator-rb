require 'mutations'

require_relative '../lib'
require_relative '../expense'
require_relative '../bills_calculator'

class CalculateBills < Mutations::Command
  required do
    array :names, class: String
    array :expenses do
      hash do
        required do
          string :spender
          float :amount
          string :description
        end

        optional do
          string :dates
        end
      end
    end
  end

  # The execute method is called only if the inputs validate. It does your business action.
  def execute
    # ensure all group members are accounted for in calculations
    no_spend = names.map { |name| Expense.new(spender: name, amount: 0) }
    with_spend = expenses.map(&Expense.method(:new))

    BillsCalculator.new(with_spend + no_spend).result
  end
end