class ResourceVersion < ApplicationRecord
  belongs_to :versionable, polymorphic: true
end
