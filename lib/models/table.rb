require_relative('cell')

class Table
  attr_reader :table

  def initialize(table)
    @table = table
  end

  def rows
    @rows ||= begin
      table.map do |row|
        row.map { |_type, content| Cell.new(content) }
      end
    end
  end

  def columns
    @columns ||= rows.transpose
  end

  def column_widths
    @column_widths ||= columns.map { |column| column.map(&:width).max }
  end

  def row_heights
    @row_heights ||= rows.map { |row| row.map(&:height).max }
  end
end
