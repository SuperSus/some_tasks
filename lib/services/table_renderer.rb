require_relative('../components/table_component')

class TableRenderer
  attr_reader :table

  def initialize(table)
    @table = table
  end

  def run
    TableComponent.new(table).render
  end
end
