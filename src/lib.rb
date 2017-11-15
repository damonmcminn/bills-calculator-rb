require 'set'
require 'bigdecimal'
require_relative 'collection'

class Array
  def uniques(key)
    map { |item| item[key] }.to_set
  end

  def to_collection
    Collection.new(self)
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
