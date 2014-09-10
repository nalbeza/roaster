require 'active_model'
require 'active_record'

require 'roaster/decorator'

class Album < ActiveRecord::Base
end

class AlbumMapping < Roaster::Decorator
end
