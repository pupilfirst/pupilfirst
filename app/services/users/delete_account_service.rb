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
        @user.reload.destroy!
      end
    end

    private

    def delete_founder_data
      # Clear timeline events that are owned just by the user
      TimelineEvent.joins(:timeline_event_owners).where(timeline_event_owners: { founder_id: @user.founders.select(:id) })
        .group('timeline_events.id').having('count(timeline_event_owners) = 1').destroy_all

      # Cache teams with only the current user as member
      teams = Startup.joins(:founders).where(founders: { id: @user.founders.select(:id) })
        .group('startups.id').having('count(founders) = 1')

      @user.founders.destroy_all
      teams.destroy_all
    end

    def delete_coach_profile
      @user.faculty.destroy
    end

    def delete_course_authors
      @user.course_authors.destroy_all
    end
  end
end
