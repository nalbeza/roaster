require 'logger'
require 'active_model'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3", :database => ':memory:'
)

if ENV['DEBUG']
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
