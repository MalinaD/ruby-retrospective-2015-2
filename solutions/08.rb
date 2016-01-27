class Spreadsheet

def initialize(table_elements = '')
  @name = 'Spreadsheet'
  @cells = table_elements.strip.split(/\n/).map do |row|
    row.strip.split(/\t|\s{2,}/).map(&:strip)
  end
  @rows = @cells.size
end

def to_s
 "#{@table_elements.gsub("  ", "\t").strip}"
end

def empty?
  @cells.empty?
end

def cell_at(cell_index)
  cell = Cell.new(cell_index)
  assert_cell_exists cell
  @cells[cell.row][cell.column]
end

def [](cell_index)
  (0...@rows).map{ |row| row_to_s(row) }.join("\n")
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
  class Error < Exception
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
      .map { |c, i| (c.ord - 'A'.ord + 1) * LETTERS ** i }
      .reduce(&:+).pred
      [row, column]
    end
  end
end

class Spreadsheet
module Formulas
  ARGUMENT_ERROR = "Wrong number of arguments for '%s': %s"

  module_function

    def add(arguments)
      light_assert('ADD', 2, arguments)
      arguments.reduce(&:+)
    end

    def multiply(arguments)
      light_assert('MULTIPLY', 2, arguments)
      arguments.reduce(&:*)
    end

    def subtract(arguments)
      strong_assert('SUBTRACT', 2, arguments)
      arguments[0] - arguments[1]
    end

    def divide(arguments)
      strong_assert('DIVIDE', 2, arguments)
      arguments[0] / arguments[1]
    end

    def mod(arguments)
      strong_assert('MOD', 2, arguments)
      arguments[0] % arguments[1]
    end

   def light_assert(formula, expected, parameters)
      if parameters.size < expected
      raise Spreadsheet::Error, "Wrong number of arguments for '#{formula}': "\
                   "expected at least #{expected}, got #{parameters.size}"
      end
    end

    def strong_assert(formula, expected, parameters)
      if parameters.size != expected
      raise Spreadsheet::Error, "Wrong number of arguments for '#{formula}': "\
                   "expected #{expected}, got #{parameters.size}"
      end
    end
end
end

class Spreadsheet
  class Formula
     NUMBER_PATTERN = /\A(\d|\.)+\z/
     FORMULA_PATTERN = %r{\A[A-Z]+\((?<param>([A-Z]+\d+|\d+\.?\d*))?
      (\s*,\s*\g<param>?)*\)\z}x
     #PATTERN = /\A([A-Z]+)\(([^\)]*)\)\z/
     VALID_FORMULA = ["ADD", "MULTIPLY", "SUBTRACT", "DIVIDE", "MOD"]

    def Formula.formula?(string)
      string =~ FORMULA_PATTERN
    end

    def value(expression)
      parameters_string = /\([A-Z\d,\s.]*\)/.match(expression)[0][1..(-2)]
      parameters = parameters_string.split(",").map(&:strip)
      formula = /[A-Z]+/.match(expression)[0]
      evaluate_formula(formula, evaluate_parameters(parameters))
    end

    def evaluate_parameters(parameters)
      parameters.map do |parameter|
        if /\A\d/ === parameter
          Float(parameter)
        else
          evaluate_cell(parameter)
        end
      end
    end

    def evaluate_formula(formula, parameters)
      validate_formula(formula)
      send(formula, downcase.to_sym, parameters)
    end

    def validate_formula(formula)
      unless VALID_FORMULA.include?(formula)
        raise Spreadsheet::Error, "Unknown function '#{formula}'"
      end
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
  unless expression?(cell)
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
  when Cell.cell?(cell)
    sheet[cell]
  when Formula.formula?(cell)
    format(Formula.new(cell).value(sheet))
  when number?(cell)
    format(cell.to_f)
  end
end

def number?(cell)
  return cell =~ /\A[+-]?[0-9]+(\.[0-9]+)?\z/
end

def format(x)
  (x % 1 == 0) ? (x.to_i.to_s) : ("%.2f" % x)
end

end
end
