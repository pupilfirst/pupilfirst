module Mutations
  class CreateSchoolLink < ApplicationQuery
    class TitleConditionallyRequired < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        title = value[:title]
        kind = value[:kind]
        return  I18n.t('mutations.create_school_link.blank_title_error') if title.blank? && kind != SchoolLink::KIND_SOCIAL
      end
    end

    include QueryAuthorizeSchoolAdmin

    argument :kind, String, required: true
    argument :title, String, required: false
    argument :url, String, required: true

    description "Create a school link."

    field :school_link, Types::SchoolLink, null: true

    validates TitleConditionallyRequired => {}

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_school_link.success_notification')
      )
      { school_link: create_school_link }
    end

    def create_school_link
      current_school.school_links.create!(create_school_link_data)
    end

    private

    def resource_school
      current_school
    end

    def create_school_link_data
      kind = @params[:kind]
      sort_index = SchoolLink.where(kind: kind).count
      data =
        case kind
        when SchoolLink::KIND_HEADER, SchoolLink::KIND_FOOTER
          { title: @params[:title], url: @params[:url] }
        when SchoolLink::KIND_SOCIAL
          {  url: @params[:url] }
        else
          raise "Unknown kind '#{kind}' encountered!"
        end

      data[:kind] = kind
      data[:sort_index] = sort_index

      data
    end
  end
end
