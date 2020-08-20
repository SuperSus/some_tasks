
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
