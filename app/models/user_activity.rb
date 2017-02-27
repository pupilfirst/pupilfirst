class UserActivity < ApplicationRecord
  belongs_to :user

  ACTIVITY_TYPE_RESOURCE_DOWNLOAD = -'resource_download'
  ACTIVITY_TYPE_FACULTY_CONNECT_REQUEST = -'faculty_connect_request'

  def self.valid_activity_types
    [ACTIVITY_TYPE_RESOURCE_DOWNLOAD, ACTIVITY_TYPE_FACULTY_CONNECT_REQUEST]
  end

  validates :activity_type, inclusion: { in: valid_activity_types }, presence: true
end
