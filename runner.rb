require 'csv'
require 'pry-nav'
require 'unicode/display_width'

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
      # contents = cell.lines
      fullsized_contents_arr = template
                               .zip(cell.lines)
                               .map { |empty_str, content| content || empty_str }

      fullsized_contents_arr.map do |content|
        CellLineComponent.new(content, cell_width: width, position: position)
      end
    end
  end
end

class CellLineComponent
  DEFAULT_STYLES = {
    padding: 3,
    space: ' ',
    border: '|'
  }.freeze

  attr_reader :content, :position, :cell_width

  def initialize(content, **options)
    @content = content
    @position = options.fetch(:position)
    @cell_width = options.fetch(:cell_width)
  end

  def render
    send("render_#{position}")
  end

  private

  def render_inner
    default_render
  end

  def render_right
    default_render
  end

  def render_left
    "#{border}#{default_render}"
  end

  def default_render
    "#{padding}#{aligned_content}#{border}"
  end

  def aligned_content
    @aligned_content ||= begin
      alignment_size = cell_width - (padding.size + content.size + borders_size)
      alignment = space * alignment_size
      "#{content}#{alignment}"
    end
  end

  def padding
    @padding ||= DEFAULT_STYLES[:space] * DEFAULT_STYLES[:padding]
  end

  def borders_size
    borders_count = position == :left ? 2 : 1
    border.size * borders_count
  end

  def space
    DEFAULT_STYLES[:space]
  end

  def border
    DEFAULT_STYLES[:border]
  end
end

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

class Cell
  attr_reader :content

  def initialize(content, _options = {})
    @content = content
  end

  def height
    lines.size
  end

  def width
    @width ||= Unicode::DisplayWidth.of(content)
  end

  def lines
    @lines ||= @content.split("\n")
  end
end

class TableRenderer
  attr_reader :table

  def initialize(table, _options = {})
    @table = table
  end

  def run
    @buffer = []
    table.each { |row| render_row(row) }
    print @buffer.join("\n")
  end

  def render_row(raw_row)
    row = raw_row.map { |_type, value| Cell.new(value) }
    height = row.map(&:height).max
    @buffer << '|' + '-' * table_width + '-|'
    height.times do
      rendered_cells = row.size.times.map do |column_index|
        column_width = column_width_by_index(column_index)
        ' ' * column_width + '|'
      end
      @buffer << rendered_cells.join
    end
  end

  def table_width
    @table_width ||= column_widths.values.sum
  end

  def column_width_by_index(index)
    column_widths.values[index]
  end

  def column_widths
    @column_widths ||= begin
      column_names = @table.headers
      column_names.each_with_object(Hash.new(0)) do |column_name, acc|
        column = table.by_col[column_name]
        column_cels = column.map { |value| Cell.new(value) }
        max_cell_width = column_cels.map(&:width).max
        acc[column_name] = max_cell_width
      end
    end
  end
end

class TableFormatter
  attr_reader :table

  def initialize(table, _options = {})
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

filename = 'lol.csv'

table = CSV.parse(File.read(filename), headers: true, col_sep: ';')

formatted_table = TableFormatter.new(table).run
renderer = TableRenderer.new(formatted_table)
renderer.run

binding.pry
