require 'time'
require 'digest/sha1'

class ObjectStore
attr_reader :objects, :instructions, :names, :date, :hash, :commit_messages

def initialize(name, object)
@date = DateTime.now
@instructions = {}
@commit_messages = {}
@objects = object
@names = name
@hash = Digest::SHA1.new
end

COMMANDS = [ :add, :commit, :remove, :get, :message, :head, :log].freeze

COMMANDS.each do |command_name|
define_method(command_name) do |arguments|
@instructions << [command_name, *arguments]
end
end

def self.init(&instructions)
instance_eval(&instructions) if instructions || block_given?
self
end

def self.message(name)
thing = name
return "Added #{thing} to stage."
end

def self.message_count(text, count)
if count == 1
return "#{text.capitalize} '\n\t' #{count} object changed"
else
return "#{text.capitalize} '\n\t' #{count} objects changed"
end
end

def self.add(name, object)
@objects = {}
@objects[name] = object
@objects[name]
self.message(name)
#TODO add more objects?
end


def self.commit(message)
count =  @objects.length
if message != "" || count != 0
date, hash_string = Time.now.rfc2822 , date.to_s + message
hash = Digest::SHA1.hexdigest(hash_string)
@objects.select do |object|
@commit_messages = {:object =>
{:message => message, :hash => hash, :date => date}}
end
@commit_messages
self.message_count(message,count)
else
return "Nothing to commit, working directory clean."
end
end

def self.remove(name)
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
