module Users
  class DeleteAccountService
    def initialize(user)
      @user = user
    end

    def execute
      raise 'user is a school admin' if @user.school_admin.present?

      User.transaction do
        delete_founder_data if @user.founders.present?
        delete_coach_profile if @user.faculty.present?
        delete_course_authors if @user.course_authors.present?
        UserMailer.confirm_account_deletion(@user.email, @user.school).deliver_later
        @user.reload.destroy!
      end
    end

    private

    def delete_founder_data
      # Clear links with all submissions, and delete submissions owned just by this user.
      TimelineEventOwner.includes(:timeline_event).where(founder: @user.founders)
        .find_each do |submission_ownership|
        submission = submission_ownership.timeline_event
        only_one_owner = submission.timeline_event_owners.one?
        submission_ownership.destroy!
        submission.destroy! if only_one_owner
      end

      # Cache teams with only the current user as member
      team_ids = Startup.joins(:founders).group(:id).having('count(founders.id) = 1').where(id: @user.founders.distinct(:startup_id).select(:startup_id)).pluck(:id)

      @user.founders.each(&:destroy!)
      Startup.where(id: team_ids).each(&:destroy!)
    end

    def delete_coach_profile
      @user.faculty.destroy!
    end

    def delete_course_authors
      @user.course_authors.each(&:destroy!)
    end
  end
end
