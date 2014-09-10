require 'logger'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3", :database => ':memory:'
)

ActiveRecord::Base.logger = Logger.new(STDOUT)
