require 'csv'
require 'pry-nav'
require 'unicode/display_width'

class CellComponent
  DEFAULT_STYLES = {
    padding: 3
  }.freeze

  attr_reader :content, :position, :width, :height

  def initialize(content, **options)
    @content = content
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
      contents = content.split("\n")
      fullsized_contents_arr = template
                               .zip(contents)
                               .map { |empty_str, content| content || empty_str }

      fullsized_contents_arr.map do |content|
        CellLineComponent.new(content, cell_width: width, position: position)
      end
    end
  end

  def line_width(line_index)
    line = lines[line_index]
    return 0 if line.nil?

    Unicode::DisplayWidth.of(line)
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

  def content_width
    @content_width ||= Unicode::DisplayWidth.of(content)
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
  attr_reader :cells

  def initialize(cells, **options)
    @cells = build_cells(cells)
  end

  def build_cells(cells)
    cells.first
  end
end

class ColumnComponent
end

class TableCOmponent
end

class Cell
  attr_reader :value

  def initialize(value, _options = {})
    @value = value
  end

  def height
    lines.size
  end

  def width
    @width ||= Unicode::DisplayWidth.of(value)
  end

  def lines
    @lines ||= @value.split("\n")
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
