module Users
  class LogProfileUpdateActivityService
    def initialize(current_user, new_name, user = nil)
      @user = user || current_user # user is nil when user == current_user
      @current_user = current_user
      @new_name = new_name
    end

    def execute
      AuditRecord.create!(
        school_id: @user.school_id,
        audit_type: AuditRecord.audit_types[:update_name],
        metadata: {
          user_id: @user.id,
          current_user_id: @current_user.id,
          old_name: @user.name,
          new_name: @new_name
        }
      )
    end
  end
end
