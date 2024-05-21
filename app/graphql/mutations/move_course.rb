module Mutations
  class MoveCourse < ApplicationQuery
    class CourseMustBePresent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        id = value[:id]
        course = Course.find_by(id: id)

        if course.blank?
          I18n.t("mutations.update_course.course_not_found_error")
        end
      end
    end

    include QueryAuthorizeSchoolAdmin

    argument :id, ID, required: true
    argument :direction, Types::MoveDirectionType, required: true

    description "Rearrange courses order"

    validates CourseMustBePresent => {}

    field :success, Boolean, null: false

    def allow_token_auth?
      true
    end

    def resolve(_params)
      { success: move_course }
    end

    def move_course
      direction = @params[:direction]

      ordered_courses =
        Course.where(school: resource_school).order(sort_index: :asc).to_a

      if direction == "Up"
        swap_up(ordered_courses, course)
      else
        swap_down(ordered_courses, course)
      end

      ordered_courses.each_with_index do |oc, index|
        oc.update!(sort_index: index)
      end

      true
    end

    private

    def course
      @course ||= Course.find_by(id: @params[:id])
    end

    def resource_school
      course&.school
    end

    def swap_up(array, element)
      index = array.index(element)

      return if index.blank? || index.zero?

      element_above = array[index - 1]
      array[index - 1] = element
      array[index] = element_above
    end

    def swap_down(array, element)
      index = array.index(element)
      swap_up(array, array[index + 1]) if index.present?
    end
  end
end
