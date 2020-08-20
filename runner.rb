require 'csv'
require 'pry-nav'
require 'unicode/display_width'

require_relative('lib/console_table')

filename = 'lol.csv'
table = ConsoleTable.new(filename)

binding.pry
