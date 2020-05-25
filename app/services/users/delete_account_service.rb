module Users
  class DeleteAccountService
    def initialize(user_id)
      @user_id = user_id
    end

    def execute
      return if user.school_admin.present?

      User.transaction do
        delete_founder_profiles if user.founders.present?
        delete_coach_profile if user.faculty.present?
        delete_course_authors if user.course_authors.present?
        nullify_applicable_records
        user.destroy
      end
    end

    private

    def user
      @user ||= User.find_by(id: @user_id)
    end

    def delete_founder_profiles
      # Clear timeline events that are owned just by the user
      TimelineEvent.joins(:timeline_event_owners).where(timeline_event_owners: { founder_id: user.founders.select(:id) })
        .group('timeline_events.id').having('count(timeline_event_owners) = 1').destroy_all

      # Cache teams with only the current user as member
      teams = Startup.joins(:founders).where(founders: { id: user.founders.select(:id) })
        .group('startups.id').having('count(founders) = 1')

      user.founders.destroy_all
      teams.destroy_all
    end

    def delete_coach_profile
      user.faculty.destroy
    end

    def delete_course_authors
      user.course_authors.destroy_all
    end

    # rubocop:disable Rails/SkipsModelValidations
    def nullify_applicable_records
      # TODO: Consider moving all below updates to model associations with dependent: :nullify
      Post.where(creator_id: @user_id).update_all(creator_id: nil)
      Post.where(editor_id: @user_id).update_all(editor_id: nil)
      MarkdownAttachment.where(user_id: @user_id).update_all(user_id: nil)
      IssuedCertificate.where(user_id: @user_id).update_all(user_id: nil)
      PostLike.where(user_id: @user_id).update_all(user_id: nil)
      TextVersion.where(user_id: @user_id).update_all(user_id: nil)
      CourseExport.where(user_id: @user_id).update_all(user_id: nil)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
