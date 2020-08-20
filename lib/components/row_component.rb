# frozen_string_literal: true

require_relative('cell_component')

class RowComponent
  attr_reader :cells, :height

  def initialize(row, cell_widths:, height:)
    @height = height
    @cells = build_cells(row, cell_widths)
  end

  def render
    height.times.map do |index|
      cells.map { |cell| cell.render(index) }.join
    end.join("\n")
  end

  private

  def build_cells(row, cell_widths)
    row.map.with_index do |cell, column_index|
      position = :inner
      position = :left if column_index.zero?
      position = :right if column_index == cell_widths.size

      CellComponent.new(
        cell,
        position: position,
        height: height,
        width: cell_widths[column_index]
      )
    end
  end
end
