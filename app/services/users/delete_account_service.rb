module Users
  class DeleteAccountService
    def initialize(user)
      @user = user
    end

    def execute
      raise "user is a school admin" if @user.school_admin.present?

      if @user.discord_user_id.present?
        Discord::ClearRolesService.new(
          @user.discord_user_id,
          Schools::Configuration::Discord.new(@user.school)
        ).execute
      end

      User.transaction do
        create_audit_record
        delete_student_data if @user.students.present?
        delete_coach_profile if @user.faculty.present?
        delete_course_authors if @user.course_authors.present?
        name = @user.preferred_name.presence || @user.name
        UserMailer.confirm_account_deletion(
          name,
          @user.email,
          @user.school
        ).deliver_later

        @user.reload.destroy!
      end
    end

    private

    def delete_student_data
      # Clear links with all submissions, and delete submissions owned just by this user.
      TimelineEventOwner
        .includes(:timeline_event)
        .where(student: @user.students)
        .find_each do |submission_ownership|
          submission = submission_ownership.timeline_event
          only_one_owner = submission.timeline_event_owners.one?
          submission_ownership.destroy!
          if only_one_owner
            submission.destroy!
          else
            # update the user_id of timeline event files to one of the other owners
            handle_timeline_event_files(submission)
          end
        end

      # Remove all page read entries associated with the user
      PageRead.where(student: @user.students).delete_all
      # Cache teams with only the current user as member
      team_ids =
        Team
          .joins(:students)
          .group(:id)
          .having("count(students.id) = 1")
          .where(id: @user.students.distinct(:team_id).select(:team_id))
          .pluck(:id)

      @user.students.each(&:destroy!)
      Team.where(id: team_ids).each(&:destroy!)
    end

    def handle_timeline_event_files(submission)
      return if submission.timeline_event_files.none?

      other_owner = submission.timeline_event_owners.reload.first
      submission.timeline_event_files.each do |file|
        file.update!(user_id: other_owner.student.user_id)
      end
    end

    def delete_coach_profile
      @user.faculty.destroy!
    end

    def delete_course_authors
      @user.course_authors.each(&:destroy!)
    end

    def create_audit_record
      AuditRecord.create!(
        audit_type: AuditRecord.audit_types[:delete_account],
        school_id: @user.school_id,
        metadata: {
          name: @user.name,
          email: @user.email,
          cohort_ids: @user.students.pluck(:cohort_id),
          organisation_id: @user.organisation_id,
          account_deletion_notification_sent_at:
            @user.account_deletion_notification_sent_at&.iso8601
        }
      )
    end
  end
end
