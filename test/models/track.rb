require 'active_model'
require 'active_record'

ActiveRecord::Migration.class_eval do
  create_table :tracks do |t|
    t.string  :title
    t.belongs_to :album
  end
end

class Track < ActiveRecord::Base
  belongs_to :album
end
