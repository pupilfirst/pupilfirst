module Schools
  module FacultyModule
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def faculty
        # A left join is required to make sure _all_ faculty is included in the following check.
        scope = Faculty.left_joins(:courses, startups: :course)

        # Note the altered table name in where condition - `courses_startup` - this is required since the table,
        # courses, is joined twice in the same query - first directly, and then through startups.
        scope.where(courses: { id: @course.id })
          .or(scope.where(courses_startups: { id: @course.id }))
      end

      def teams(faculty)
        return 'All' if faculty.id.in?(course_faculty_ids)

        faculty.startups.pluck(:name).join(', ')
      end

      private

      def course_faculty_ids
        @course_faculty_ids ||= @course.faculty.pluck(:id)
      end
    end
  end
end
