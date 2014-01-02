require 'rufus/scheduler'
require 'json'
require 'yaml'
require 'ostruct'

SCHEDULER = Rufus::Scheduler.start_new

settings = OpenStruct.new
settings.root = Dir.pwd

def development?
  ENV['RACK_ENV'] == 'development'
end

def production?
  ENV['RACK_ENV'] == 'production'
end

def send_event(id, body, target=nil)
  body[:updatedAt] ||= Time.now.to_i
  body[:auth_token] = ENV['AUTH_TOKEN']

  HTTParty.post("#{ENV['ENDPOINT']}/widgets/#{id}", :body => body.to_json)
end

{}.to_json # Forces your json codec to initialize (in the event that it is lazily loaded). Does this before job threads start.

job_path = ENV["JOB_PATH"] || 'jobs'
files = Dir[File.join(settings.root, job_path, '**', '/*.rb')]
files.each { |job| require(job) }
