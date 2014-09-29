require 'active_model'
require 'active_record'

ActiveRecord::Migration.class_eval do
  create_table :tracks do |t|
    t.string  :title
    t.references :album
    t.references :album_as_bonus
  end
end

class Track < ActiveRecord::Base
  belongs_to :album
  belongs_to :album_as_bonus, :class_name => :Album
end
