class UpdateSchoolStringMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :key
  attr_accessor :value

  validates :key, inclusion: { in: SchoolString::VALID_KEYS, message: 'InvalidKey' }
  validates :value, length: { maximum: 10_000, message: 'InvalidLengthValue' }, allow_blank: true

  def update_school_string
    SchoolString.transaction do
      if value.present?
        school_string = SchoolString.where(school: current_school, key: key).first_or_create!
        school_string.value = value.strip
        school_string.save!
      else
        SchoolString.where(school: current_school, key: key).destroy!
      end
    end
  end
end
