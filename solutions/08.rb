class Spreadsheet

attr_accessor :rows, :columns, :table_elements

def initialize(table_elements)
  @name = 'Spreadsheet'
  @rows = []
  @columns = []
  @table_elements = table_elements
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
else return false
end
end

#def cell_at(cell_index)

#end

#def [](cell_index)

#end

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