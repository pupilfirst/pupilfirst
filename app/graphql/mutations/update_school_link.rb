module Mutations
  class UpdateSchoolLink < ApplicationQuery
    class SchoolLinkMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        link = SchoolLink.find_by(id: value[:id])

        return "Unable to find link with id: #{value[:id]}" if link.blank?
      end
    end

    class TitleConditionallyRequired < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        title = value[:title]
        kind = value[:kind]
        if title.blank? && kind != SchoolLink::KIND_SOCIAL
          return(I18n.t("mutations.update_school_link.blank_title_error"))
        end
      end
    end

    class ValidTitleLength < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        title = value[:title]
        return unless title

        if title.length < 1 || title.length > 24
          return(
            I18n.t("mutations.update_school_link.invalid_title_length_error")
          )
        end
      end
    end

    include QueryAuthorizeSchoolAdmin

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :url, String, required: false

    description "Update school header/footer/social links"

    field :success, Boolean, null: false

    validates SchoolLinkMustBePresent => {}
    validates TitleConditionallyRequired => {}
    validates ValidTitleLength => {}

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.update_school_link.success_notification")
      )

      { success: update_school_link }
    end

    def update_school_link
      school_link.update!(title: @params[:title], url: @params[:url])
    end

    private

    def school_link
      SchoolLink.find_by(id: @params[:id])
    end

    def resource_school
      school_link&.school
    end
  end
end
