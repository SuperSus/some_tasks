class RowComponent
  attr_reader :cells, :height

  def initialize(cells, height:)
    @cells = cells
    @height = height
  end

  def render
    height.times.map do |index|
      cells.map { |cell| cell.render(index) }.join
    end.join("\n")
  end
end
