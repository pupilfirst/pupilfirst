class UpdateSchoolMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
  property :about, validates: { length: { maximum: 500 } }

  def update_school
    current_school.name = name
    current_school.about = about if about.present?
    current_school.save!
  end
end
