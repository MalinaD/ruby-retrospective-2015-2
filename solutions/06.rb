module TurtleGraphics
class Turtle
  DIRECTIONS = [:up, :right, :down, :left]

  def initialize(rows = 0, columns = 0)
    @matrix = create_matrix(rows, columns)
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
  @row %= @rows
  @column %= @columns
  step_at(@row, @column)
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
    @direction = direction
  end

 def spawn_at(row, column)
    @spawned = true

    @row = row
    @column = column

    step_at(@row, @column)
  end

 private

def create_matrix(rows, columns)
  Array.new(rows) { Array.new(columns, 0) }
end

def step_at(row, column)
  @matrix[row][column] += 1
end

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

    def find_max_element
      @matrix.reduce(@matrix.first.max) do |current_max, row|
        row_max = row.max
        row_max > current_max ? row_max : current_max
      end
    end
    
    def intensity_matrix
      max_element = find_max_element

      @matrix.map { |row| row.map { |cell| cell.to_f / max_element } }
    end
  end
 

class HTML < Base

  def initialize(pixels)
  	@pixels = pixels
  end

  def process(matrix)
    html_beginning + table(matrix) + closing_tags
  end

  private

def html_beginning
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
  <body>"
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
  "<table>" +
    matrix.intensity_matrix.map { |row| pixels_row(row) }.join("\n") +
    "</table>"
end

def closing_tags
  "</body></html>"
end

end

    class Default < Base
    end

end
end