class CreateSchoolLinkMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :kind, validates: { inclusion: { in: SchoolLink::VALID_KINDS, message: 'InvalidKind' } }
  property :title, validates: { length: { minimum: 1, maximum: 24, message: 'InvalidLengthTitle' }, allow_nil: true }
  property :url, validates: { url: { message: 'InvalidUrl' }, presence: { message: 'BlankUrl' } }

  validate :title_conditionally_required

  def title_conditionally_required
    return if title.present? || kind == SchoolLink::KIND_SOCIAL

    errors[:base] << 'BlankTitle'
  end

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

    current_school.school_links.create!(params)
  end

  private

  def resource_school
    current_school
  end
end
