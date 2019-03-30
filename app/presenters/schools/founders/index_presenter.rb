module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        {
          teams: teams,
          courseId: @course.id,
          courseCoachIds: @course.faculty.pluck(:id),
          schoolCoaches: coach_details(@course.school.faculty.includes(:image_attachment)),
          levels: levels,
          studentTags: founder_tags,
          authenticityToken: view.form_authenticity_token
        }
      end

      def teams
        @course.startups.includes(:level, :faculty, founders: %i[user taggings avatar_attachment]).order(:id).map do |team|
          {
            id: team.id,
            name: team.product_name,
            students: student_details(team.founders),
            coaches: team.faculty.pluck(:id),
            levelNumber: team.level.number
          }
        end
      end

      private

      def student_details(students)
        students.map do |student|
          {
            id: student.id,
            name: student.name,
            avatarUrl: avatar_url(student),
            teamId: student.startup.id,
            teamName: student.startup.product_name,
            email: student.user.email,
            tags: student.tag_list & founder_tags,
            exited: student.exited
          }
        end
      end

      def coach_details(coaches)
        coaches.map do |coach|
          {
            id: coach.id,
            name: coach.name,
            avatarUrl: coach.image_or_avatar_url
          }
        end
      end

      def course_coaches
        @course_coaches ||= coach_details(@course.faculty)
      end

      def levels
        @levels ||= @course.levels.map do |level|
          {
            name: level.name,
            number: level.number
          }
        end
      end

      def avatar_url(founder)
        if founder.avatar.attached?
          view.url_for(founder.avatar_variant(:mid))
        else
          founder.initials_avatar
        end
      end

      def founder_tags
        @founder_tags ||= @course.school.founder_tag_list
      end
    end
  end
end
