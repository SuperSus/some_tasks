# frozen_string_literal: true

class TableFormatter
  attr_reader :table

  def initialize(table)
    @table = table.dup
  end

  def run
    table.each { |row| format_row!(row) }
  end

  private

  def format_row!(row)
    row.each_with_index do |cell, index|
      type, value = cell
      row[index] = send("format_#{type}", value)
    end
  end

  def format_int(value)
    value.to_s
  end

  def format_string(value)
    words = value.scan(/\w+/)
    words.join("\n")
  end

  def format_money(value)
    whole_part, fractional_part = value.split('.')

    limited_fractional_part = fractional_part[0..1]
    formatted_whole_part = whole_part.reverse.gsub(/.{3}/, '\0 ').reverse.strip

    [formatted_whole_part, limited_fractional_part].join(',')
  end
end
