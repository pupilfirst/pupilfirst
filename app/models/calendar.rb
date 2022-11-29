class Calendar < ApplicationRecord
  belongs_to :course
  has_many :calendar_events, dependent: :destroy
end
