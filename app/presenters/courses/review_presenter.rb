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
        current_coach: current_coach_details
      }
    end

    def current_coach_details
      {
        name: current_user.name,
        avatar_url: current_user.image_or_avatar_url,
        title: current_user.title
      }
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
        timeline_event.attributes.slice('id', 'target_id', 'created_at')
          .merge(title: timeline_event.target.title)
          .merge(timeline_event.target.target_group.slice('level_id'))
          .merge(user_names: user_names(timeline_event)).merge(status: nil)
      end
    end

    def user_names(timeline_event)
      timeline_event.founders.map do |founder|
        founder.user.name
      end.join(', ')
    end
  end
end
