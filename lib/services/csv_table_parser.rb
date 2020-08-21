# frozen_string_literal: true

require 'csv'

class CSVTableParser
  COLUMN_SEPARATOR = ';'

  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def run
    CSV.parse(File.read(filename), headers: true, col_sep: COLUMN_SEPARATOR)
  end
end
