require_relative('cell_component')
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
    rows.each { |row| buffer << row.render }
    buffer << border

    buffer.join("\n")
  end

  def border
    '+' + '-' * width + ''
  end

  def rows
    @rows ||= begin
      table.rows.map.with_index do |row, row_index|
        row_cells = row.map.with_index do |cell, column_index|
          CellComponent.new(
            cell,
            position: :inner,
            height: row_heights[row_index],
            width: column_widths[column_index] + padding
          )
        end

        RowComponent.new(row_cells, height: row_heights[row_index])
      end
    end
  end

  def width
    @width ||= column_widths.sum
  end

  def column_widths
    @column_widths ||= table.column_widths.map { |width| width + padding }
  end

  def row_heights
    table.row_heights
  end

  def padding
    DEFAULT_STYLES[:padding]
  end
end
