require 'time'
require 'digest/sha1'

class Response
attr_reader :message, :result

def initialize(message, success, result = nil)
	@message, @success, @result = message, success, result
end

def success?
	@success
end

def error?
	not @success
end

end

class Change
  attr_reader :action, :name, :object

  def initialize(action, name, object = nil)
    @action, @name, @object = action, name, object
  end
end

class ObjectStore
attr_reader :branch
attr_accessor :current_branch

def self.init(&block)
    instance = self.new
    instance.instance_eval(&block) if block_given?
    instance
end

def initialize(&block)
	#@branch = BranchDecorator.new self
    @pending_changes = Hash.new
    @history = Hash.new
    @current_branch = "master"
    self.instance_eval &block if block_given?
	#@hash = Digest::SHA1.new
end

#COMMANDS = [ :add, :commit, :remove, :get, :message, :head, :log].freeze

#COMMANDS.each do |command_name|
#	define_method(command_name) do |arguments|
#		@instructions << [command_name, *arguments]
#	end
#end

def message(name)
	thing = name
	return "Added #{thing} to stage."
end

def message_count(text, count)
	if count == 1
		return "#{text.capitalize} '\n\t' #{count} object changed"
	else
		return "#{text.capitalize} '\n\t' #{count} objects changed"
	end
end

def add(name, object)
	@pending_changes[name] = Change.new(:add, name, object)
	Response.new "Added #{name} to stage.", true, object
end


def commit(message)
	count =  @pending_changes.size
	if message != "" || count != 0
		date, hash_string = Time.now.rfc2822 , date.to_s + message
		hash = Digest::SHA1.hexdigest(hash_string)
		@pending_changes.select do |object|
			@commit_messages = {:object =>
			{:message => message, :hash => hash, :date => date}}
		end
			@commit_messages
			self.message_count(message,count)
	else
		return "Nothing to commit, working directory clean."
	end
end

      def head
        if @current_branch.commit.empty?
          Result.new("Branch #{@current_branch.name}" \
            " does not have any commits yet.", false, true)
        else
          last_commit = @current_branch.commits.last
          Result.new(last_commit.message, true, false, last_commit)
        end
      end

def remove(name)
	for_removing = self.get('name')
	if for_removing == nil
		return "Object #{name} is not committed."
	else
		for_removing.delete
		return "Added #{name} for removal. '\n '" + for_removing
	end
end

def success?

end

def error?

end

def self.head
	last_object, final_result = @commit_messages.values.last , nil
	if last_object == nil
		return "Branch #{name} does not have any commits yet"
	else
		#message, hash, date = last_object.values_at(:message, :hash, :date)
		final_result = result
		return final_result.to_s
	end
end

def self.result
	last = @commit_messages.values.last
	message, hash, date = last.values_at(:message, :hash, :date)
	final_result = message + " " + hash + " " + date
	return final_result
end


def self.get(name)
	taken_object = ""
	@objects.select do |object|
	if object[name] == name
		taken_object = @objects[name]
	end
end.first

	if taken_object == ""
		return "Object #{name} is not commited."
	else
		return "Found object #{name}." + " \n " + taken_object
	end
end

def self.log
end

end

class Branch
#TODO
end
