require 'rufus/scheduler'
require 'json'
require 'yaml'
require 'ostruct'

SCHEDULER = Rufus::Scheduler.start_new

settings = OpenStruct.new
settings.root = Dir.pwd
# Persist history in tmp file at exit
# at_exit do
#   File.open(settings.history_file, 'w') do |f|
#     f.puts settings.history.to_yaml
#   end
# end

# if File.exists?(settings.history_file)
#   set history: YAML.load_file(settings.history_file)
# else
#   set history: {}
# end

def development?
  ENV['RACK_ENV'] == 'development'
end

def production?
  ENV['RACK_ENV'] == 'production'
end

def send_event(id, body, target=nil)
  #body[:id] = id
  body[:updatedAt] ||= Time.now.to_i
  body[:auth_token] = ENV['AUTH_TOKEN']
  #event = format_event(body.to_json, target)
  #Sinatra::Application.settings.history[id] = event unless target == 'dashboards'
  #Sinatra::Application.settings.connections.each { |out| out << event }
  p body
  HTTParty.post("#{ENV['ENDPOINT']}/widgets/#{id}", :body => body.to_json)
end

def format_event(body, name=nil)
  str = ""
  str << "event: #{name}\n" if name
  str << "data: #{body}\n\n"
end

# settings_file = File.join(settings.root, 'config/settings.rb')
# if (File.exists?(settings_file))
#   require settings_file
# end

#Dir[File.join(settings.root, 'lib', '**', '*.rb')].each {|file| require file }
{}.to_json # Forces your json codec to initialize (in the event that it is lazily loaded). Does this before job threads start.

job_path = ENV["JOB_PATH"] || 'jobs'
files = Dir[File.join(settings.root, job_path, '**', '/*.rb')]
files.each { |job| require(job) }
