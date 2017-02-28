class UserActivity < ApplicationRecord
  belongs_to :user

  ACTIVITY_TYPE_RESOURCE_DOWNLOAD = -'Resource Download'
  ACTIVITY_TYPE_FACULTY_CONNECT_REQUEST = -'Faculty Connect Request'

  def self.valid_activity_types
    [ACTIVITY_TYPE_RESOURCE_DOWNLOAD, ACTIVITY_TYPE_FACULTY_CONNECT_REQUEST]
  end

  validates :activity_type, inclusion: { in: valid_activity_types }, presence: true
end
