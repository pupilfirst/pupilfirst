module Mutations
  class CreateSchoolLink < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    include ValidateSchoolLinkTitle

    argument :kind, String, required: true
    argument :title, String, required: false
    argument :url, String, required: true

    description "Create a school link."

    field :school_link, Types::SchoolLink, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.create_school_link.success_notification")
      )
      { school_link: create_school_link }
    end

    def create_school_link
      data =
        case @params[:kind]
        when SchoolLink::KIND_HEADER, SchoolLink::KIND_FOOTER
          { title: @params[:title], url: @params[:url] }
        when SchoolLink::KIND_SOCIAL
          { url: @params[:url] }
        else
          raise "Unknown kind '#{@params[:kind]}' encountered!"
        end

      data[:kind] = @params[:kind]
      data[:sort_index] = SchoolLink
        .where(kind: @params[:kind], school: resource_school)
        .maximum(:sort_index)
        .to_i + 1

      current_school.school_links.create!(data)
    end

    private

    def resource_school
      current_school
    end
  end
end
