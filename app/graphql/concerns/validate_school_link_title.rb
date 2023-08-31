module ValidateSchoolLinkTitle
  extend ActiveSupport::Concern

  class ValidTitleLength < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      title = value[:title]&.strip
      kind =
        if value[:id].present?
          link = SchoolLink.find_by(id: value[:id])
          link&.kind
        else
          value[:kind]
        end

      if (kind.present?) && (kind != SchoolLink::KIND_SOCIAL) &&
           (title.length < 1 || title.length > 24)
        return(I18n.t("validate_school_link_title.title_length_error"))
      end
    end
  end

  included { validates ValidTitleLength => {} }
end
