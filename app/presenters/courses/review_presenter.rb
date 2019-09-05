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
        authenticity_token: view.form_authenticity_token,
        levels: levels,
        submissions: submissions,
        users: users
      }
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def submissions
      @submissions ||= @course.timeline_events.pending_review.includes(:founders, target: :target_group).map do |timeline_event|
        timeline_event.attributes.slice('id', 'target_id', 'created_at')
          .merge(title: timeline_event.target.title)
          .merge(timeline_event.target.target_group.slice('level_id'))
          .merge(user_ids: timeline_event.founders.pluck(:user_id))
      end
    end

    def users
      @users ||= current_school.users.where(id: @submissions.pluck(:user_ids).flatten.uniq).map do |user|
        user.attributes.slice('id', 'name')
      end
    end
  end
end
