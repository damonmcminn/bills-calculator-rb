require 'set'
require 'bigdecimal'
require 'csv'

class Array
  def uniques_by(method_name)
    map { |item| item.send(method_name) }.to_set
  end

  def sum(property)
    reduce(0) do |total, obj|
      next total if obj.nil?

      value = obj.send(property)

      if value.nil?
        total
      else
        total + value
      end
    end
  end

  def filter_map(test, cast)
    select(&test).map(&cast)
  end
end

class CSV
  def self.hashify(str)
    title, headers, *rows = parse str

    mapped_rows = rows.map do |row|
      r = {}
      headers.each.with_index do |header, index|
        r[header.snake_case.to_sym] = row[index] if header
      end
      r
    end

    [title, mapped_rows]
  end
end

class String
  def snake_case
    downcase.gsub(' ', '_')
  end
end

class Numeric
  def to_money
    value = to_f.round(2).to_s
    value += '0' if value.split('.').last.size == 1
    value
  end

  def essentially_zero?
    self.abs.to_f <= Float::EPSILON
  end
end
