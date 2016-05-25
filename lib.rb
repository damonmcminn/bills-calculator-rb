require 'set'

class Array
  def uniques(key)
    map { |item| item[key] }.to_set
  end
end

class CSV
  def self.hashify(file)
    headers, *rows = read file

    rows.map do |row|
      r = {}
      headers.each.with_index do |header, index|
        r[header.snake_case.to_sym] = row[index]
      end
      r
    end
  end
end

class String
  def snake_case
    downcase.gsub(' ', '_')
  end
end
