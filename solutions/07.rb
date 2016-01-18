module LazyMode

class Date
attr_reader :date

def initialize(date)
	@date = date
end

def year
	current_year = @date.to_s.split('-').first
	  if(current_year.to_i < 1000)
	 	current_year.to_s.insert(0,'0')
	  end
    current_year
end

def month
	current_month = @date.to_s.split('-')[1]

	if(current_month.to_i < 10)
 		current_month.to_s.insert(0,'0')
	  end
    current_month
end

def day
	current_day = @date.to_s.split('-').last

 	if(current_day.to_i < 10)
 		current_day.to_s.insert(0,'0')
	end
  current_day
end

def to_s
  "#{year}-#{month}-#{day}"
end

end

class Note < Struct.new(:header, :body, :status, :tags)
	def self.new_note(header, body, status, tags)
      Note.new(header.strip.downcase.to_sym,
               body.strip,
               status.strip.downcase.to_sym,
               tags.split(',').map(&:strip))
    end
end

class File

    def initialize(name, notes = [])
      @notes = notes
      @name = name
    end

    def each(&block)
      @notes.each &block
    end

    def self.create_file(name = File.new.name)
       @notes[name] = notes
    end

    def self.name
      file_name = "#{@name}"
    end

    def note
      notes = Note.new_note
      header = "#{@notes.header}"
      tags = "#{@notes.tags}".join(" , ")
      status = "#{@notes.status}"
      body = "#{@notes.body}"
      size = @notes.size
    end

    def scheduled(some_date)
      current_date = LazyMode::Date.new(some_date)
      scheduled_date = current_date

      case occurence
      when 'm' then end_date = current_date.month + 1
      when 'd' then end_date = current_date.day + 1
      when 'w' then end_date = current_date.day + 7
       end
    end

    def serialize
      file = "#{@notes.size}:#{serialize_entities(@name)}"

      "#{file}"
    end

    protected
    attr_reader :notes, :name
end

    def self.create_file(name = File.new.name)
    end

end