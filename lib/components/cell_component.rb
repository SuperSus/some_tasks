require_relative('cell_line_component')

class CellComponent
  DEFAULT_STYLES = {
    padding: 3
  }.freeze

  attr_reader :cell, :position, :height, :width

  def initialize(cell, **options)
    @cell = cell
    @position = options.fetch(:position)
    @width = options.fetch(:width)
    @height = options.fetch(:height)
  end

  def render(line_index)
    lines[line_index].render
  end

  private

  def lines
    @lines ||= begin
      template = Array.new(height, '')
      fullsized_contents_arr = template
                                .zip(cell.lines)
                                .map { |empty_str, content| content || empty_str }

      fullsized_contents_arr.map do |content|
        CellLineComponent.new(content, cell_width: width, position: position)
      end
    end
  end
end
