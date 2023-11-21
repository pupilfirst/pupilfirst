class UserStanding < ApplicationRecord
  belongs_to :user
  belongs_to :standing
  belongs_to :creator, class_name: "User"
  belongs_to :archiver, class_name: "User", optional: true

  validates :reason, presence: true
end
