class CreateSchoolLinkMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :kind
  attr_accessor :title
  attr_accessor :url

  validates :kind, inclusion: { in: SchoolLink::VALID_KINDS, message: 'InvalidKind' }
  validates :title, presence: { message: 'MaxGradeBlank' }, length: { minimum: 1, maximum: 24 }
  validates :url, url: true, presence: true

  def create_school_link
    params = case kind
      when SchoolLink::KIND_HEADER, SchoolLink::KIND_FOOTER
        { title: title, url: url }
      when SchoolLink::KIND_SOCIAL
        { url: url }
      else
        raise "Unknown kind '#{kind}' encountered!"
    end

    params[:kind] = kind
    params[:school] = current_school

    SchoolLink.create!(params)
  end
end
