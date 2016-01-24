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

class TrueResult < Response
  def initialize(message, result = nil)
    super(message, true, result)
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
	@branch = Branch.new self
    @pending_changes = Hash.new
    @history = Hash.new
    @current_branch = "master"
    self.instance_eval &block if block_given?
end

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
	set_head Commit.new(head.result, @pending_changes, message)
	@history[head.result.hash] = head.result
	@pending_changes = Hash.new
	if count > 0
        Response.new "#{message}\n\t#{count} objects changed", true, head.result
	else
		Response.new "Nothing to commit, working directory clean.", false
	end
end

def head
	result = @branch.heads[@current_branch]
	if result != nil
	  Response.new result.message, true, result
	else
	  Response.new "Branch #{current_branch} does not have any commits yet.", false
	end
end

def set_head(value)
	@branch.heads[@current_branch] = value
end

def checkout(commit_hash)
	if @history.has_key? commit_hash
		set_head @history[commit_hash]
		Response.new "HEAD is now at #{commit_hash}.", true, head.result
	else
		Response.new "Commit #{commit_hash} does not exist.", false
	end
end

def remove(name)
	search = get(name)
	if search.error?
		Response.new "Object #{name} is not committed.", false
	else
		@pending_changes[name] = Change.new(:remove, name)
		Response.new "Added #{name} for removal.", true, search
	end
end

def result
	last = @commit_messages.values.last
	message, hash, date = last.values_at(:message, :hash, :date)
	final_result = message + " " + hash + " " + date
	return final_result
end


def get(name)
	taken_object = head.result.get(name) unless head.error?

	if taken_object != nil
		Response.new "Found object #{name}.", true, taken_object
	else
		Response.new "Object #{name} is not commited.", false
	end
end

def log
	if head.success?
      Response.new head.result.log, true
    else
      Response.new "Nothing to commit, working directory clean.", false
    end
end

end

class Commit
attr_reader :date, :message, :hash

TIME_FORMAT = "%a %b %d %H:%M %Y %z"

def initialize(parent_commit, changes, message)
	@parent_commit, @changes, @message = parent_commit, changes, message
	@date = Time.now
	formatted_time = @date.getgm.strftime(Commit::TIME_FORMAT)
	@hash = Digest::SHA1.hexdigest "#{formatted_time}#{message}"
end

def size
	@changes.size
end

def get(name)
	if @changes.has_key? name
		change = @changes[name]
		change.object unless change.action == :remove
	else
		@parent_commit.get(name)  unless @parent_commit == nil
	end
end

def objects(excluding = Array.new)
	total = Array.new
	if @parent_commit != nil
		total_exclude = excluding || @changes.map{ |key, value| key}
		total = @parent_commit.objects(total_exclude)
	end

	total.concat(@changes.select {|key, value|
		value.action == :add unless excluding.incude?(value.name)}
		.map {|key, value| value.object })
end

def to_s
	formatted_time = @date.strftime(Commit::TIME_FORMAT)
	"Commit #{hash}\nDate: #{formatted_time}\n\n\t#{message}"
end

def log
	if @parent_commit != nil
		to_s + "\n\n" + @parent_commit.log
	else
		to_s
	end
end

end

class Branch
attr_reader :heads

def initialize(repository)
	@repository = repository
	@heads = Hash.new
	@heads["master"] = nil
end

def create(branch_name)
	if @heads.has_key? branch_name
		Response.new "Branch #{branch_name} already exists.", false
	else
		@heads[branch_name] = @repository.head
		Response.new "Created branch #{branch_name}.", true
	end
end

def checkout(branch_name)
	if @heads.has_key? branch_name
		@repository.current_branch = branch_name
		Response.new "Switched to branch #{branch_name}.", true
	else
		Response.new "Branch #{branch_name} does not exist.", false
	end
end

def remove(branch_name)
	if @heads.has_key? branch_name
		if branch_name != @repository.current_branch
			@heads.delete branch_name
			Response.new "Removed branch #{branch_name}.", true
		else
			Response.new "Cannot remove current branch.", false
		end
	else
		Response.new "Branch #{branch_name} does not exists.", false
	end
end

def list()
	branches_list = ""
    @repository.branch.sort! { |a, b| a.name <=> b.name }
    @repository.branch.each do |branch|
      prefix = (branch.name == @repository.current_branch.name ? '* ' : '  ' )
      branches_list += prefix + branch.name + "\n"
    end

    branches_list.chomp!
    TrueResult.new(branches_list)
end


def log
	if @heads.has_key? branch_name
	  message = @repository.current_branch.reverse.map(&:to_s).join("\n\n")
	  Response.new(true, message)
	else
	  branch_name = branch.active_branch.name
	  Response.new(false, "Branch #{branch_name} does not have any commits yet.")
	end
end

end
