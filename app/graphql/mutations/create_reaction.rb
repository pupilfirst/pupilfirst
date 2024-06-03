module Mutations
  class CreateReaction < ApplicationQuery
    argument :reaction_value, String, required: true
    argument :reactionable_id, String, required: true
    argument :reactionable_type, String, required: true

    description "Create a reaction on either a submission or comment"

    field :reaction, Types::ReactionType, null: false

    def resolve(_params)
      params = {
        reaction_value: @params[:reaction_value],
        reactionable_id: @params[:reactionable_id],
        reactionable_type: @params[:reactionable_type],
        user_id: current_user.id
      }
      reaction = Reaction.new(params)
      r = reaction.save ? reaction : Reaction.find_by!(params)

      if @params[:reactionable_type] == "TimelineEvent"
        Notifications::CreateJob.perform_later(
          :reaction_created,
          current_user,
          r
        )
      end

      { reaction: r }
    end

    def query_authorized?
      return false if current_user.blank?

      return false if course&.school != current_school

      return true if current_school_admin.present?

      return true if current_user.course_authors.where(course: course).present?

      return true if course.faculty.exists?(user: current_user)

      student.present?
    end

    def student
      @student ||=
        current_user
          .students
          .joins(:cohort)
          .find_by(cohorts: { course_id: course })
    end

    def submission
      if @params[:reactionable_type] == "TimelineEvent"
        @submission ||= TimelineEvent.find_by(id: @params[:reactionable_id])
      else
        @submission ||=
          SubmissionComment.find_by(id: @params[:reactionable_id]).submission
      end
    end

    def course
      @course ||= submission&.course
    end
  end
end
