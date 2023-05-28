module Schools
  module Courses
    class ApplicantsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course
        super(view_context)
      end

      def props
        {
          course_id: @course.id,
          tags: tags,
          selected_applicant: applicant_data
        }
      end

      private

      def applicant_data
        return if @applicant.blank?

        {
          name: @applicant.name,
          email: @applicant.email,
          tags: @applicant.taggings.map { |tagging| tagging.tag.name },
          id: @applicant.id
        }
      end

      def tags
        @tags ||= current_school.student_tag_list
      end
    end
  end
end
