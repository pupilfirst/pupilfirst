class UpdateSchoolMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
  property :about, validates: { length: { maximum: 500 } }

  def update_school
    current_school.update!(name: name, about: about)
  end

  private

  def resource_school
    current_school
  end
end
