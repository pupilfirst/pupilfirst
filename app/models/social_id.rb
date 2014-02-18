class SocialId < ActiveRecord::Base
  belongs_to :user
  serialize :permission, Array
end
