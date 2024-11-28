#!/usr/bin/env ruby

require 'rexml'
require 'json'

$stdout.sync = true

class State < Struct.new(:cells, :selection)
  def initialize
    state = REXML::Functions.json_parse(File.read("state.json"))

    @cells = state[:@cells].map do |key, value|
      [REXML::Functions.json_parse(key.to_s), value]
    end.to_h
  end

  def to_xml
    cells = @cells.map do |(col, row), value|
      "  <cell col=\"#{col.to_i}\" row=\"#{row.to_i}\">#{value.to_i}</cell>"
    end

    "<cells>\n#{cells.join("\n")}\n</cells>"
  end

  def query(query)
    doc = REXML::Document.new(to_xml)
    REXML::XPath.match(doc, query)
  end

  def clear(nodes)
    return if nodes.nil?

    nodes.each do |node|
      node.text = ""
    end
  end

  def set(value, nodes)
    return if nodes.nil?

    nodes.each do |node|
      node.text = value.to_i
    end
  end

  def render(cells = @cells)
    keys = cells.keys
    minx, maxx = keys.map(&:first).minmax
    miny, maxy = keys.map(&:last).minmax
    cell_width = cells.values.map { _1.to_s.size }.max + 1

    [].tap do |output|
      output << ("+-" + "-" * cell_width) * maxx + "+\n"
      (miny..maxy).each do |y|
        (minx..maxx).each do |x|
          cell = cells[[x, y]].to_s.ljust(cell_width)
          output << "| #{cell}"
        end
        output << "|\n"
        output << ("+-" + "-" * cell_width) * maxx
        output << "+\n"
      end
    end.join
  end
end

module REXML::Functions
  def self.export_xml
    STATE.to_xml
  end

  def self.import_xml(*_)
    # importing xml is dangerous. we'll do it later.
    "todo: import_xml"
  end

  def self.json_parse(value)
    # at least json is safe to parse
    JSON.parse(value, symbolize_names: true)
  end

  def self.json_get(json, key)
    key = string(key)
    json[key] or json[key.to_sym]
  end

  def self.json_key(json, value)
    json.key(value)
  end

  def self.select(x1, y1, x2, y2)
    filters = [
      "@col >= #{y1.to_i}",
      "@col <= #{y2.to_i}",
      "@row >= #{x1.to_i}",
      "@row <= #{x2.to_i}"
    ]

    STATE.query("//cell[#{filters.join(' and ')}]")
  end

  def self.clear(nodes = nil)
    STATE.clear(nodes)
  end

  def self.set(value, nodes = nil)
    STATE.set(value, nodes)
  end

  def self.render
    STATE.render
  end

  def self.source
    @source ||= File.read(__FILE__).split("__#{'END'}__").first
  end

  def self.help
    @help ||= DATA.read
  end
end


STATE = State.new

puts "XSpreadsheet 23.129-3348.1"
puts "Type help() for help."
puts

loop do
  print "> "

  begin
    query = gets
    exit if query.nil?
  rescue Interrupt
    exit
  end

  begin
    puts STATE.query(query)
  rescue Exception => e
    warn(e)
    puts "error"
  end

  puts
end

__END__

Functions:

- help():
  Show this documentation.

- source():
  Show the source code.

- select(col1, row1, col2, row2):
  Select the cells contained in the rectangle from [col1, row1] to [col2, row2]

- clear([cells]):
  Clear the given cells or the current selection.

- render():
  Output a visual representation of the spreadsheet.

- export_xml():
  Output the spreadsheet in XML format.

- json_parse(value):
  Parse a value into JSON.

- json_get(json, key):
  Get the value a key of a JSON object.

- json_key(json, value):
  Get the key of a value of a JSON object.


Example Queries:

- Basic math:
  3 * 45

- Select cells in the column 2:
  //cell[@col=2]

- Sum of cells in the first 2 columns and rows:
  sum(select(1, 1, 2, 2)

- Select the last cell:
  //cell[last()]

- Set all cells to 0:
  set(0, //cell)
