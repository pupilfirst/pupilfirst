module Mutations
  class MoveSchoolLink < ApplicationQuery
    class SchoolLinkMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        id = value[:id]
        link = SchoolLink.find_by(id: id)

        if link.blank?
          return I18n.t('mutations.update_school_link.link_not_found_error')
        end
      end
    end

    include QueryAuthorizeSchoolAdmin

    argument :id, ID, required: true
    argument :direction, Types::MoveDirectionType, required: true

    description 'Rearrange school links'

    validates SchoolLinkMustBePresent => {}

    field :success, Boolean, null: false

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.update_school_link.success_notification')
      )

      { success: move_school_link }
    end

    def move_school_link
      direction = @params[:direction]
      ordered_school_links =
        SchoolLink
          .where(kind: school_link.kind, school: resource_school)
          .order(sort_index: :ASC)
          .to_a

      if direction == 'Up'
        swap_up(ordered_school_links, school_link)
      else
        swap_down(ordered_school_links, school_link)
      end

      ordered_school_links.each_with_index do |cb, index|
        cb.update!(sort_index: index)
      end

      true
    end

    private

    def school_link
      SchoolLink.find_by(id: @params[:id])
    end

    def resource_school
      school_link&.school
    end

    def swap_up(array, element)
      index = array.index(element)

      return array if index.zero? || index.blank?

      element_above = array[index - 1]
      array[index - 1] = element
      array[index] = element_above
      array
    end

    def swap_down(array, element)
      index = array.index(element)
      swap_up(array, array[index + 1])
    end
  end
end
