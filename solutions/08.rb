class Spreadsheet

attr_accessor :rows, :cells, :table_elements

def initialize(table_elements = '')
  @name = 'Spreadsheet'
  @cells = table_elements.strip.split(/\n/).map do |row|
    row.strip.split(/\t|\s{2,}/).map(&:strip)
  end
  @rows = @cells.size
  @table_elements = parse_elements table_elements
end

def new
  p ""
end

def new(table_elements)
  @table_elements << table_elements.lines.map(&:chomp)
  @table_elements.each do |maxes, rows|
    rows.split(/(\t)/).strip do |value, column|
      maxes[column] = [(maxes[column] || 0), value.to_s.length].max
      #if value[0] == "="
      #  formula_name = value.partition('=').first
      #  first_element = value.match("\((\d+)\)")[1]
      #  second_element = value.match("\(\d+))\)")[1]
      #  case formula_name
      #    when "ADD" then add(first_element)
          # when "MULTIPLY"  multiply()
      #  end
     # end
    end
    maxes
  end
end

def to_s
 "#{@table_elements.gsub("  ", "\t").strip}"
end

def empty?
if @table_elements == ""
  return true
else 
  return false
end
end

def cell_at(cell_index)
  cell = Cell.new(cell_index)
  assert_cell_exists cell
  @cells[cell.row][cell.column]
end

def [](cell_index)
  (0...@rows).map{ |row| row_to_s(row) }.join("\n")
end

def parse_elements(elements)
  rows = elements.split("\n").select { |item| ! (item =~ /^\s*$/) }.map(&:strip)
  rows.map { |row| row.split(/\t|(?:\ {2,})/) }
end

  class Error < StandardError
  end

private

  def assert_cell_exists(cell)
    unless cell.row < @rows and cell.column < @cells[cell.row].size
      raise Error, "Cell '#{cell}' does not exist"
    end
  end

  def row_to_s(row)
    values = (0...@cells[row].size).map do |column|
      Expressions.evaluate_string(@cells[row][column], self)
    end

    values.join("\t")
  end
end

class Spreadsheet
  class Cell
    LETTERS = 'Z'.ord - 'A'.ord + 1
    PATTERN = /\A([A-Z]+)(\d+)\z/

    def Cell.cell?(string)
      string =~ PATTERN
    end

    attr_reader :row, :column

    def initialize(index)
      assert_cell(index)
      @index = index
      @row, @column = to_numbers(index)
    end

    def to_s
      @index
    end

    private

    def assert_cell(index)
      unless Cell.cell? index
        raise Error, "Invalid cell index '#{index}'"
      end
    end

    def to_numbers(index)
      column, row = index.match(PATTERN).captures
      row = row.to_i.pred
      column = column.split(//).reverse.each_with_index
      .map{|c, i| (c.ord - 'A'.ord + 1) * LETTERS ** i }
      .reduce(&:+).pred
      [row, column]
    end

  end
end

class Spreadsheet
module Formulas
  ARGUMENT_ERROR = "Wrong number of arguments for '%s': %s"

  module_function

    def add(argument_one, argument_two, *optional)
      if optional == nil
        argument_one + argument_two
      else
      argument_one + argument_two +
        (optional.inject(0) { |sum, number| sum + number })
      end
    end

    def multiply(argument_one, argument_two, *optional)
      if optional == nil
        argument_one * argument_two
      else
        argument_one * argument_two *
        (optional.inject(0) { |value, number| value * number })
      end
    end

    def subtract(argument_one, argument_two)
      argument_one - argument_two
    end

   # def divide(argument_one, argument_two)
   #   argument_one / argument_two
   # end
end
end

class Spreadsheet
  class Formula
    PATTERN = /\A([A-Z]+)\(([^\)]*)\)\z/

    def Formula.formula?(string)
      string =~ PATTERN
    end  

  end
end

class Spreadsheet
module Expressions
module_function

def expression?(string)
  string.start_with? '='
end

def evaluate_string(cell, sheet)
  unless  expression?(cell)
    return cell
  end
  evaluate_expression(cell[1 .. -1], sheet)
end
    
def evaluate_expression(cell, sheet)
  evaluate_safely(cell, sheet) or
  raise Error, "Invalid expression '#{cell}'"
end

def evaluate_safely(cell, sheet)
  case 
  when Cell.cell?(cell) then sheet[cell]
  when number?(cell) then format(cell.to_f)
  #when Formula.formula?(cell) then format(Formula.new(cell).value(sheet))
  end
end

def number?(cell)
  return cell =~ /\A[+-]?[0-9]+(\.[0-9]+)?\z/
end

def format(value)
  (value % 1 == 0) ? (value.to_i.to_s) : ("%2f" % value)
end

end
end
