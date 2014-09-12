require 'active_model'
require 'active_record'

require 'roaster/decorator'

ActiveRecord::Migration.class_eval do
  create_table :albums do |t|
    t.string  :title
  end
end

class Album < ActiveRecord::Base
end

class Band < ActiveRecord::Base
end

class BandMapping < Roaster::Decorator
  property :name
end

class AlbumMapping < Roaster::Decorator
  property :title
  property :created_at

  can_include :band, :tracks

  can_filter_by :band

  can_sort_by :title, :created_at
end
