require 'mutations'

require_relative '../lib'
require_relative '../expense'
require_relative '../bills_calculator'
require_relative 'azure_storage_table'
require_relative 'bills_storage'

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

  def execute
    # ensure all group members are accounted for in calculations
    no_spend = names.map { |name| Expense.new(spender: name, amount: 0) }
    with_spend = expenses.map(&Expense.method(:new))

    calculated = BillsCalculator.new(with_spend + no_spend).result

    BillsStorage.create({
      results: calculated,
      names: names,
      expenses: expenses
    })
  end
end