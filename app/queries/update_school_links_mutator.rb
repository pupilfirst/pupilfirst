class UpdateSchoolLinksMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :id, validates: { presence: true }
  property :title,
           validates: {
             length: {
               minimum: 1,
               maximum: 24,
               message: 'InvalidLengthTitle'
             },
             allow_nil: true
           }
  property :url,
           validates: {
             url: {
               message: 'InvalidUrl'
             },
             presence: {
               message: 'BlankUrl'
             },
             allow_nil: true
           }

  def save
    params = { title: title, url: url }
    school_link.update!(params)
  end

  private

  def school_link
    @school_link ||= current_school.school_links.find_by(id: id)
  end

  def resource_school
    current_school
  end
end
