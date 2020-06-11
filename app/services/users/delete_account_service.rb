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
      # Clear timeline events that are owned just by the user
      timeline_event_owners = TimelineEventOwner.where(founder: @user.founders)

      tes = TimelineEvent.joins(:timeline_event_owners)
        .where(timeline_event_owners: { id: timeline_event_owners.select(:id) })
        .select { |event| event.timeline_event_owners.count == 1 }

      TimelineEvent.where(id: tes).destroy_all

      timeline_event_owners.destroy_all

      # Cache teams with only the current user as member
      team_ids = Startup.joins(:founders).group(:id).having('count(founders.id) = 1').where(id: @user.founders.distinct(:startup_id).select(:startup_id)).pluck(:id)

      @user.founders.destroy_all
      Startup.where(id: team_ids).destroy_all
    end

    def delete_coach_profile
      @user.faculty.destroy
    end

    def delete_course_authors
      @user.course_authors.destroy_all
    end
  end
end
