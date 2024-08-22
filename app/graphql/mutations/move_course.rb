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
    argument :target_position_course_id, ID, required: true

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
      target_position_course =
        resource_school.courses.find_by(id: @params[:target_position_course_id])

      return false if target_position_course.blank? || course.blank?

      Course.transaction do
        course_index = course.sort_index
        course.update!(sort_index: target_position_course.sort_index)
        target_position_course.update!(sort_index: course_index)

        reset_sort_index
      end

      true
    end

    private

    def reset_sort_index
      resource_school.courses.order(sort_index: :asc).to_a.each_with_index do |oc, index|
        next if oc.sort_index.eql?(index)

        oc.update!(sort_index: index)
      end
    end

    def course
      @course ||= Course.find_by(id: @params[:id])
    end

    def resource_school
      course&.school
    end
  end
end
