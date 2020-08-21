# frozen_string_literal: true

require_relative('row_component')

class TableComponent
  DEFAULT_STYLES = {
    padding: 3
  }.freeze

  attr_reader :table

  def initialize(table)
    @table = table
  end

  def render
    buffer = []

    buffer << border
    rows.each do |row|
      buffer << row.render
      buffer << border
    end

    buffer.join("\n")
  end

  def rows
    @rows ||= begin
      table.rows.map.with_index do |row, row_index|
        RowComponent.new(
          row,
          cell_widths: column_widths,
          height: row_heights[row_index]
        )
      end
    end
  end

  def border
    @border ||= begin
      spans = column_widths.map do |width|
        "#{'-' * (width - 1)}+"
      end
      "+#{spans.join[1..-1]}"
    end
  end

  def width
    @width ||= column_widths.sum
  end

  def column_widths
    @column_widths ||= table.column_widths.map { |width| width + padding + 2 }
  end

  def row_heights
    table.row_heights
  end

  def padding
    DEFAULT_STYLES[:padding]
  end
end
