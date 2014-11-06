class MentorSkill < ActiveRecord::Base
  belongs_to :mentor, class_name: 'User'
  belongs_to :skill, class_name: 'Category'

  EXPERTISE_NOVICE = 'novice'
  EXPERTISE_INTERMEDIATE = 'intermediate'
  EXPERTISE_ADVANCED = 'advanced'
  EXPERTISE_EXPERT = 'expert'

  def self.valid_expertise_values
    [EXPERTISE_NOVICE, EXPERTISE_INTERMEDIATE, EXPERTISE_ADVANCED, EXPERTISE_EXPERT]
  end

  validates_presence_of :mentor
  validates_presence_of :skill
  validates_inclusion_of :expertise, in: valid_expertise_values, allow_nil: true

  nilify_blanks
end
