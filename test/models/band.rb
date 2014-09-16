require 'active_model'
require 'active_record'

ActiveRecord::Migration.class_eval do
  create_table :bands do |t|
    t.string  :name
  end
end

class Band < ActiveRecord::Base
end
