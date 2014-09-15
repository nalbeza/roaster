require 'active_model'
require 'active_record'

require 'representable'
require 'representable/json'

require 'roaster/decorator'

ActiveRecord::Migration.class_eval do
  create_table :albums do |t|
    t.string  :title
    t.belongs_to :band
  end
end

ActiveRecord::Migration.class_eval do
  create_table :bands do |t|
    t.string  :name
  end
end

class Album < ActiveRecord::Base
  belongs_to :band
end

class Band < ActiveRecord::Base
end

class BandMapping < Roaster::Decorator
  include Representable::Hash

  property :name
end

class AlbumMapping < Roaster::Decorator

  include Representable::Hash

  property :title
  #property :created_at

  can_include :band, :tracks

  can_filter_by :band

  can_sort_by :band, :title, :created_at

  collection_representer class: Album
end
