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

class Commit
attr_reader :date, :message, :hash

TIME_FORMAT = "%a %b %d %H:%M %Y %z"

def initialize(message, objects)
	@objects, @message = objects, message
	@date = Time.now
	formatted_time = @date.getgm.strftime(Commit::TIME_FORMAT)
	@hash = Digest::SHA1.hexdigest "#{formatted_time}#{message}"
end

def objects
	@objects.values
end

def objects_hash
	@objects
end

def to_s
	formatted_time = @date.strftime(Commit::TIME_FORMAT)
	"Commit #{hash}\nDate: #{formatted_time}\n\n\t#{message}"
end

end

class Branches
	class Branch
		attr_reader :name
		attr_accessor :commits

		def initialize(name, commits = [])
			@name = name
			@commits = commits
		end
    end

attr_reader :current_branch

def initialize
	@branches = {'master' => Branch.new('master')}
	@current_branch = @branches['master']
end

def create(branch_name)
	if branch_exists? branch_name
		Response.new "Branch #{branch_name} already exists.", false
	else
		new_branch = Branch.new(branch_name, @current_branch.commits.clone)
		@branches[branch_name] = new_branch
		Response.new "Created branch #{branch_name}.", true
	end
end

def checkout(branch_name)
	if branch_exists? branch_name
		@current_branch = @branches[branch_name]
		Response.new "Switched to branch #{branch_name}.", true
	else
		Response.new "Branch #{branch_name} does not exist.", false
	end
end

def remove(branch_name)
	if not branch_exists? branch_name
		Response.new false, "Branch #{branch_name} does not exists."
	elsif current_branch? branch_name
		Response.new "Cannot remove current branch.", false
	else
		@branches.delete branch_name
		Response.new "Removed branch #{branch_name}.", true
	end
end

def list
	branches_list = @branches.sort.map do |_, branch|
        "#{current_branch? branch.name ? '*' : ' '} #{branch.name}"
      end.join("\n")

    Response.new(branches_list, true)
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

private

def branch_exists?(branch_name)
	@branches[branch_name]
end

def current_branch?(branch_name)
	@current_branch.name == branch_name
end

end

def initialize(&block)
	@branches = Branches.new
	@pending_changes = Hash.new
    @history = Hash.new
    @objects_to_remove = []
    self.instance_eval &block if block_given?
end

def self.init(&block)
    instance = self.new
    instance.instance_eval(&block) if block_given?
    instance
end

def branch
	@branches
end

def add(name, object)
	@pending_changes[name] = Change.new(:add, name, object)
	Response.new "Added #{name} to stage.", true, object
end

def remove(name)
	if head.error? or not head.result.objects_hash[name]
		Response.new "Object #{name} is not committed.", false
	else
		object = head.result.objects_hash[name]
		@pending_changes[name] = object
		@objects_to_remove << name
		Response.new "Added #{name} for removal.", true, object
	end
end

def commit(message)
	if @pending_changes.empty?
		Response.new "Nothing to commit, working directory clean.", false
	else
		count = @pending_changes.size
		branch.current_branch.commits << Commit.new(message, commit_objects)
		clear_pending_changes
		Response.new "#{message}\n\t#{count} objects changed", true, head.result
	end
end

def checkout(commit_hash)
	commit_hashes = branch.current_branch.commits.map {|commit| commit.hash }
	commit_index = commit_hashes.find_index(commit_hash)
	if commit_index
		commits = branch.current_branch.commits
        commits.pop(commits.size - commit_index - 1)
		Response.new "HEAD is now at #{commit_hash}.", true, head.result
	else
		Response.new "Commit #{commit_hash} does not exist.", false
	end
end

def log
	if branch.current_branch.commits.empty?
	  branch_name = branch.current_branch.name
      Response.new "Branch #{branch_name} does not have any commits yet.", false
    else
      message = branch.current_branch.commits.reverse.map(&:to_s).join("\n\n")
      Response.new message, true
    end
end

def head
	result = branch.current_branch.commits
	if result.empty?
	  branch_name = branch.current_branch.name
	  Response.new "Branch #{branch_name} does not have any commits yet.", false
	else
	  last_commit = branch.current_branch.commits.last
	  Response.new last_commit.message, true, last_commit
	end
end

def get(name)
	if head.error? or not head.result.objects_hash[name]
		Response.new "Object #{name} is not commited.", false
	else
		Response.new "Found object #{name}.", true, head.result.objects_hash[name]
	end
end


 private

  def commit_objects
    head_objects = head.success? ? head.result.objects_hash : {}
    objects = head_objects.merge(@pending_changes)
    @objects_to_remove.each { |name| objects.delete(name) }

    objects
  end

  def clear_pending_changes
    @pending_changes.clear
    @objects_to_remove.clear
  end

end
