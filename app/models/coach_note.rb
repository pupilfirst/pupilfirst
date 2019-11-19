class CoachNote < ApplicationRecord
  belongs_to :author, class_name: 'Faculty'
  belongs_to :student, class_name: 'Founder'

  validates :note, presence: true
end
