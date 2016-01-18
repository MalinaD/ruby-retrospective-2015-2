module TurtleGraphics
#I did not have much time, but i will be glad of at least a small comment
class Turtle
  attr_accessor :position, :rows, :cols, :marks
  attr_reader :left, :right, :commands

  def initialize(rows, cols)
  	@rows = rows
  	@cols = cols
    @position, @marks = Array.new(@rows) { Array.new(@cols, 0) }, []
    @commands
  end

  def move
    @position += 1
  end

  def mark
    marks << @position
  end

COMMAND = [:move, :mark, :turn_right, :turn_left].freeze

    COMMAND.each do |command_name|
      define_method command_name do | *arguments |
        @instructions << [command_name, *arguments]
      end
    end

def self.draw
 turtle = Turtle.new position
 turtle.instance_eval &commands
 turtle.commands
 case commands
    when 'move' then puts '1'
    when 'mark' then puts '4'
	when 'turn_right' then puts '2'
	when 'turn_left' then puts '3'
 end
end

end

class Canvas
 attr_reader :canvas

      def initialize(canvas)
        @canvas = canvas
      end

class HTML
 attr_reader :pixels

  def initialize(pixels)
  	@pixels = pixels
  end

  def set_values(width, height)
      @pixels[[width, height]] = true
  end

TEMPLATE = '<!DOCTYPE html>
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
      width: 5px;
      height: 5px;

      background-color: black;
      padding: 0;
    }
  </style>
</head>
<body>
  <table>
    <tr>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 0.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 1.00"></td>
      <td style="opacity: 1.00"></td>
    </tr>
    <tr>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
      <td style="opacity: 0.00"></td>
    </tr>
  </table>
</body>
</html>'.freeze

def render
	TEMPLATE % super
end

end
end
end