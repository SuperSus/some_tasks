# frozen_string_literal: true

require_relative('services/csv_table_parser')
require_relative('services/table_formatter')
require_relative('services/table_renderer')
require_relative('models/table')

class ConsoleTable
  attr_reader :table

  def initialize(source_file)
    raw_table = parse_source_file(source_file)
    formatted_table = format_table(raw_table)
    @table = build_table(formatted_table)
  end

  def show
    puts render_table(table)
  end

  private

  def parse_source_file(source_file)
    CSVTableParser.new(source_file).run
  end

  def format_table(table)
    TableFormatter.new(table).run
  end

  def build_table(table)
    Table.new(table)
  end

  def render_table(table)
    TableRenderer.new(table).run
  end
end
