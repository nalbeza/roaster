require 'active_model'
require 'active_record'

ActiveRecord::Migration.class_eval do
  create_table :albums do |t|
    t.string  :title
    t.belongs_to :band
  end
end

class Album < ActiveRecord::Base
  belongs_to :band
  has_many :tracks
end
