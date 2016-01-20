class LazyMode
  def self.create_file(file_name, &block)
    file = File.new(file_name)
    file.instance_eval(&block)

    file
  end

class Date
@@period_table = {"d" => 1, "w" => 7, "m" => 30}

attr_reader :year, :month, :day

def self.to_date(days)
  calculated_day = days % 30 == 0 ? 30 : days % 30
  calculated_month = sprintf('%02d', (((days - calculated_day) / 30) + 1) % 12)
  calculated_year = sprintf('%04d', ((days - calculated_day) / 360 + 1))
  calculated_month = "12" if calculated_month == "00"

  Date.new("#{calculated_year}-#{calculated_month}-#{sprintf('%02d', calculated_day)}")
end

def initialize(date_string)
	@year, @month, @day, @repetition = date_string.split(/[-, +]/, 4)
  @year, @month, @day = [@year, @month, @day].map{|time| time.to_i }
  @date_string = date_string[0..9]
end

def ===(date)
  difference = data.to_days - self.to_days
  return false if difference < 0
  period ? difference % period == 0 : difference == 0
end

def period
  return nil if @repetition == nil
  jump = @repetition.scan(/\d*/).join("").to_i
  type = @repetition.match(/[dwm]/).to_s
  jump * @@period_table[type]
end

def to_days
  (year - 1) * 360 + (month - 1) * 30 + day
end

def within_week(date)
      occurence = [0,1,2,3,4,5,6].map { |day| date.to_days + day }
                                 .map{ |days| Date.to_date(days) }
                                 .delete_if { |date| !(self === date) }
      occurence
    end

def to_s
   "%04d-%02d-%02d" % [@year, @month, @day]
end

end

class Note #< Struct.new(:header, :body, :status, :tags)
	#def new_note(header, body, status, tags)
   #   Note.new(header.strip.downcase.to_sym,
    #           body.strip,
    #           status.strip.downcase.to_sym,
     #          tags.split(',').map(&:strip))
  #end

attr_accessor :tags, :file, :header, :date

  def initialize(file, header)
    @file = file
    @header = header
    @status = :topostpone
    @body = ""
  end

  def body(new_body = nil)
    @body = new_body if new_body

    @body
  end

  def file_name
    @file.name
  end

  def note(header, *tags, &block)
    new_note = Note.new(@file, header)
    new_note.tags = tags
    new_note.instance_eval(&block)
    @file.notes.push(new_note)
    new_note
  end

  def scheduled(date)
      @date = Date.new(date)
  end

  def status(new_status = nil)
  @status = new_status if new_status

  @status
  end

end

class File
attr_accessor :name, :notes

    def initialize(name)
      @notes = []
      @name = name
    end

    def each(&block)
      @notes.each &block
    end

    def create_file(name = File.new.name)
       @notes[name] = notes
    end

   # def name
   #   file_name = "#{@name}"
   # end

    def note(header, *tags, &block)
      new_note = Note.new(@file, header)
     new_note.tags = tags
     new_note.instance_eval(&block)
     @notes.push(new_note)

     new_note
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

end

end