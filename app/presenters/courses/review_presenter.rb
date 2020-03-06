module Courses
  class ReviewPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Review Dashboard | #{@course.name} | #{current_school.name}"
    end

    private

    def props
      {
        levels: levels,
        pending_submissions: pending_submissions,
        course_id: @course.id,
        current_coach: current_coach_details,
        team_coaches: StudentsPresenter.new(view, @course).team_coaches
      }
    end

    def current_coach_details
      coach = current_user.faculty

      details = {
        id: coach.id,
        user_id: current_user.id,
        name: current_user.name,
        title: current_user.full_title
      }

      details[:avatar_url] = view.rails_representation_path(current_user.avatar_variant(:thumb), only_path: true) if current_user.avatar.attached?
      details
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def students
      @students ||= Founder.where(startup_id: current_coach.reviewable_startups(@course))
    end

    def pending_submissions
      @pending_submissions ||= TimelineEvent.pending_review.from_founders(students).includes(founders: :user, target: :target_group).map do |timeline_event|
        team_ids = timeline_event.founders.map(&:startup_id).uniq
        coach_ids = FacultyStartupEnrollment.where(startup_id: team_ids).pluck(:faculty_id)

        timeline_event.attributes.slice('id', 'target_id', 'created_at')
          .merge(timeline_event.target.target_group.slice('level_id'))
          .merge(
            user_names: user_names(timeline_event),
            title: timeline_event.target.title,
            status: nil,
            coach_ids: coach_ids
          )
      end
    end

    def user_names(timeline_event)
      timeline_event.founders.map do |founder|
        founder.user.name
      end.join(', ')
    end
  end
end
