require 'csv'
require 'trollop'
require 'terminal-table'
require 'clipboard'
require 'ostruct'
require 'http'
require 'yaml'

require_relative 'src/monkey_patches'
require_relative 'src/expense'
require_relative 'src/bills_calculator'

opts = Trollop.options do
  opt :gid, 'Sheet Id', type: String
  opt :clipboard, 'Copy to clipboard'
end

Trollop.die 'Need to specify a CSV file' unless opts[:gid]

spreadsheet_id = YAML.load_file('config.yml')['spreadsheet_id']
sheet = "https://docs.google.com/spreadsheets/d/#{spreadsheet_id}/pub?gid=#{opts[:gid]}&single=true&output=csv"
sheet_link = "https://docs.google.com/spreadsheets/d/#{spreadsheet_id}/view#gid=#{opts[:gid]}"

lines = HTTP.get(sheet).to_s

title_row, rows = CSV.hashify(lines)
bills = rows.map { |row| Expense.new(row) }
calc = BillsCalculator.new(bills)

payments = calc.result.payments.map { |p| [p[:from], p[:to], p[:amount]] }
payments_table = Terminal::Table.new title: 'Payments', rows: payments
payments_table.headings = ['from', 'to', { value: 'amount', alignment: :right }]
payments_table.align_column(2, :right)

spenders = calc.result.spenders.map do |s|
  [s[:name], s[:share], s[:total_spend], s[:owes]]
end
spenders_table = Terminal::Table.new title: 'Individual Spend', rows: spenders
spenders_table.headings = ['name',
                           { value: 'share', alignment: :right },
                           { value: 'total spend', alignment: :right },
                           { value: 'owes', alignment: :right }]
(1..3).each { |index| spenders_table.align_column(index, :right) }

expenses = calc.result.expenses.map do |e|
  [e[:description], e[:dates], e[:total]]
end
expenses_table = Terminal::Table.new rows: expenses
expenses_table.title = 'Bills & Household Expenses'
expenses_table.headings = ['type',
                           { value: 'dates', alignment: :right },
                           { value: 'total', alignment: :right }]
(1..2).each { |index| expenses_table.align_column(index, :right) }

output = <<~HEREDOC
Bills: #{title_row.first}
Line items: #{sheet_link}

#{payments_table}

#{spenders_table}

#{expenses_table}
HEREDOC

puts output

Clipboard.copy output if opts[:clipboard]
