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
        submissions: pending_submissions,
        course_id: @course.id,
        grade_labels: @course.grade_labels_to_props,
        pass_grade: @course.pass_grade
      }
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def pending_submissions
      @pending_submissions ||= @course.timeline_events.pending_review.includes(founders: :user, target: :target_group).map do |timeline_event|
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
