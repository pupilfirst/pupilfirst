module Users
  class ActivityService
    def initialize(user)
      @user = user
    end

    def create(activity_type, metadata)
      @user.user_activities.create!(
        user_id: @user.id,
        activity_type: activity_type,
        metadata: metadata
      )
    end
  end
end
