module TurtleGraphics
class Turtle
  DIRECTIONS = [:up, :right, :down, :left]

  def initialize(rows = 0, columns = 0)
    @matrix = Array.new(rows) { Array.new(columns, 0) }
  	@rows = rows
  	@columns = columns
    @column = 0
    @row = 0
    @direction = :right
    @spawned = false
  end

def move
  spawn_at(0, 0) unless @spawned
  case @direction
    when :up    then @row -= 1
    when :down  then @row += 1
    when :right then @column += 1
    when :left  then @column -= 1
  end
  @row, @column = (@row % @rows), (@column % @columns)
  @matrix[@row][@column] += 1
end

def draw(canvas = Canvas::Default.new, &block)
 instance_eval(&block)
 canvas.process(@matrix)
end

 def turn_left
    change_direction(:left)
  end

  def turn_right
    change_direction(:right)
  end

  def look(direction)
    raise 'Invalid orientations' unless DIRECTIONS.include? direction
    @direction = direction
  end

 def spawn_at(row, column)
    @spawned = true
    @row = row
    @column = column
    @matrix[@row][@column] += 1
  end

 private

def change_direction(direction)
  current_direction_index = DIRECTIONS.index(@direction)

  if direction == :right
    current_direction_index += 1
  else
    current_direction_index -= 1
  end

  current_direction_index %= DIRECTIONS.length
  @direction = DIRECTIONS[current_direction_index]
end

end

module Canvas

class Base
    def process(matrix)
      matrix
    end

    private

    def to_proportions(matrix)
      max_item = matrix.flatten.max

      matrix_proportions = matrix.map do |row|
        row.map { |element| element / max_item.to_f }
      end

      matrix_proportions
    end
end

class ASCII < Base

def initialize(symbols)
  @symbols = symbols
end

def process(matrix)
  proportions = to_proportions(matrix)
  to_ascii(proportions)
end

private

def to_ascii(matrix)
  symbols_matrix = matrix.map do |row|
      row_symbols = row.map { |element| ascii_element element }
          row_symbols.join
  end

  symbols_matrix.join("\n")
end

def ascii_element(percent)
  steps = @symbols.length
  interval = 1.0 / (steps - 1)
  percent = percent.round(2)

  steps.times do |step|
    return @symbols[step] if percent <= (interval * step).round(2)
  end
end

end

class HTML < Base

  def initialize(pixels)
  	@pixels = pixels
  end

  def process(matrix)
    proportions = to_proportions(matrix)
    add_html(proportions)
  end

  private

def add_html(matrix)
  "<!DOCTYPE html>
  <html>
  <head>
    <title>Turtle graphics</title>

    <style>
      table {
        border-spacing: 0;
      }

      tr {
        padding: 0;
      }

      td {
        width: #{@pixels}px;
        height: #{@pixels}px;

        background-color: black;
        padding: 0;
      }
    </style>
  </head>
  <body><table>#{table(matrix)}</table>" + closing_tags
end

def pixel(opacity)
  "<td style=\"opacity: #{opacity}\"></td>"
end

def pixels_row(matrix_row)
  "<tr>" +
    matrix_row.map { |intensity| pixel(format('%.2f', intensity)) }.join("\n") +
    "</tr>"
end

def table(matrix)
    proportions_html = matrix.map do |proportion|
          pixels_row(proportion)
        end
    proportions_html.join
end

def closing_tags
  "</body></html>"
end

end

class Default < Base
end

end
end