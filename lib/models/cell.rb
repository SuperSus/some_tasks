require 'unicode/display_width'

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
