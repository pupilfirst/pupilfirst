module Mutations
  class CreateTopic < ApplicationQuery
    include QueryAuthorizeCommunityUser
    argument :title,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 250
               }
             }
    argument :body,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 15_000
               }
             }
    argument :community_id, ID, required: true
    argument :target_id, ID, required: false
    argument :topic_category_id, ID, required: false

    description 'Create a new topic of discussion in a community'

    field :topic_id, ID, null: true

    def resolve(_params)
      new_topic =
        Topic.transaction do
          topic =
            Topic.create!(
              title: @params[:title],
              community: community,
              target_id: target&.id,
              topic_category: topic_category,
              last_activity_at: Time.zone.now
            )

          topic.posts.create!(
            post_number: 1,
            body: @params[:body],
            creator: current_user
          )

          create_subscribers(topic)

          topic
        end

      Notifications::CreateJob.perform_later(
        :topic_created,
        current_user,
        new_topic
      )

      Discord::NotificationJob.perform_later(:topic_created, new_topic)

      { topic_id: new_topic.id }
    end

    private

    alias query_authorized? authorized_create?

    def community
      @community ||= Community.find_by(id: @params[:community_id])
    end

    def topic_category
      return if @params[:topic_category_id].blank?

      community.topic_categories.find_by(id: @params[:topic_category_id])
    end

    def create_subscribers(topic)
      users =
        User
          .joins(faculty: :faculty_student_enrollments)
          .where(
            faculty: {
              faculty_student_enrollments: {
                student_id: current_user.students.active
              }
            }
          )
          .where.not(id: current_user.id)
          .distinct + [current_user]

      users.each { |user| TopicSubscription.create!(user: user, topic: topic) }
    end

    def target
      @target ||=
        begin
          t = Target.find_by(id: @params[:target_id])

          if t.present? && t.course.school == current_school &&
               target_accessible?(t)
            t
          end
        end
    end

    def target_accessible?(some_target)
      current_school_admin.present? || current_user.faculty.present? ||
        current_user
          .students
          .joins(:course)
          .exists?(courses: { id: some_target.course.id })
    end
  end
end
