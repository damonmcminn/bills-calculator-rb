require 'csv'
require 'trollop'
require 'terminal-table'
require 'clipboard'

# monkeypatches et al
require_relative 'src/lib'
require_relative 'src/expense'
require_relative 'src/bills_calculator'

opts = Trollop.options do
  opt :file, 'CSV file', type: String
  opt :clipboard, 'Copy to clipboard'
end

Trollop.die 'Need to specify a CSV file' unless opts[:file]

bills = CSV.hashify(opts[:file]).map(&Expense.method(:new))
calc = BillsCalculator.new(bills)

payments = calc.result[:payments].map { |p| [p[:from], p[:to], p[:amount]] }
payments_table = Terminal::Table.new title: 'Payments', rows: payments
payments_table.headings = ['from', 'to', { value: 'amount', alignment: :right }]
payments_table.align_column(2, :right)

spenders = calc.result[:spenders].map do |s|
  [s[:name], s[:share], s[:total_spend], s[:owes]]
end
spenders_table = Terminal::Table.new title: 'Individual Spend', rows: spenders
spenders_table.headings = ['name',
                           { value: 'share', alignment: :right },
                           { value: 'total spend', alignment: :right },
                           { value: 'owes', alignment: :right }]
[1, 2, 3].each { |index| spenders_table.align_column(index, :right) }

expenses = calc.result[:expenses].map do |e|
  [e[:description], e[:dates], e[:total]]
end
expenses_table = Terminal::Table.new rows: expenses
expenses_table.title = 'Bills & Household Expenses'
expenses_table.headings = ['type',
                           { value: 'dates', alignment: :right },
                           { value: 'total', alignment: :right }]
[1, 2].each { |index| expenses_table.align_column(index, :right) }

result = [
  payments_table,
  spenders_table,
  expenses_table
].join("\n\n")

puts result

Clipboard.copy result if opts[:clipboard] 