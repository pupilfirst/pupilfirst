module Mutations
  class SortSchoolLinks < ApplicationQuery
    class SchoolLinkMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        link_ids = value[:link_ids]
        link = SchoolLink.where(id: link_ids, kind: value[:kind])

        if link.count != link_ids.counts
          return "Unable to find link with id: #{value[:id]}"
        end
      end
    end

    include QueryAuthorizeSchoolAdmin

    # include ValidateSchoolLinkEditable

    argument :link_ids, [ID], required: true
    argument :kind, String, required: false

    description 'Rearrange school links'

    field :success, Boolean, null: false

    # validates SchoolLinkMustBePresent => {}

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.done_exclamation'),
        'School link sorted'
        # I18n.t('mutations.update_school_link.success_notification')
      )

      { success: sort_school_links }
    end

    def sort_school_links
      school_link.each do |link|
        link.update!(sort_index: @params[:link_ids].index(link.id.to_s))
      end
    end

    private

    def school_link
      SchoolLink.where(id: @params[:link_ids], kind: @params[:kind])
    end

    def resource_school
      current_school
    end
  end
end
