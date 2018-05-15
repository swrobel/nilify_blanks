require "rubygems"
require "rspec"
require "active_support"
require "active_record"
require "yaml"

# Establish DB Connection
config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'db', 'database.yml')))
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
config = ActiveRecord::Base.configurations['test']
if %w[mysql postgresql].include?(ENV['DB'])
  ActiveRecord::Base.establish_connection(config.merge('database' => nil)) if ENV['DB'] == 'mysql'
  ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres')) if ENV['DB'] == 'postgresql'
  ActiveRecord::Base.connection.recreate_database(config['database'], config)
end
ActiveRecord::Base.establish_connection(config)

# Load Test Schema into the Database
load(File.dirname(__FILE__) + "/db/schema.rb")

require File.dirname(__FILE__) + '/../init'
