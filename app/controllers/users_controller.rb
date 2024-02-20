class UsersController < ApplicationController
  before_action :authenticate_user!, except: :delete_account
  layout "student"

  # GET /dashboard/
  def dashboard
    @user = authorize(current_user)
  end

  # GET /user/edit
  def edit
    @user = authorize(current_user)

    if session.key?(:course_requiring_discord)
      redirect_to discord_account_required_user_path
    end
  end

  # GET /users/delete_account
  def delete_account
    user =
      Users::ValidateDeletionTokenService.new(
        params[:token],
        current_school
      ).authenticate
    if user.present?
      sign_in user
      @token = params[:token]
    else
      flash[:error] = t(".link_expired")
      redirect_to root_path
    end
  end

  # POST /user/upload_avatar
  def upload_avatar
    @form = Users::UploadAvatarForm.new(current_user)
    if @form.validate(params[:user])
      avatar_url = @form.save
      render json: { avatarUrl: avatar_url }
    else
      render "edit"
    end
  end

  # POST /user/clear_discord_id
  def clear_discord_id
    if current_user.discord_user_id.present?
      Discord::ClearRolesJob.perform_later(
        current_user.discord_user_id,
        current_school
      )
      current_user.update!(discord_user_id: nil)
    end

    flash[:success] = t(".success")
    redirect_to edit_user_path
  end

  # GET /user/update_email
  def update_email
    user =
      Users::ValidateUpdateEmailTokenService.new(
        params[:token],
        current_school
      ).authenticate

    if user.present? && user.new_email.present?
      old_email = user.email
      new_email = user.new_email

      # Update user email
      user.update!(email: new_email, update_email_token: nil, new_email: nil)

      # Create audit record
      AuditRecord.create!(
        audit_type: AuditRecord.audit_types[:update_email],
        school_id: current_school.id,
        metadata: {
          user_id: current_user.id,
          email: new_email,
          old_email: old_email
        }
      )

      # Send success email to user - both old and new email for security
      UserMailer.confirm_email_update(user, user.email, old_email).deliver_later

      UserMailer.confirm_email_update(user, old_email, old_email).deliver_later

      # Send notification email to admins
      current_school
        .school_admins
        .where.not(user_id: user.id)
        .each do |admin|
          SchoolAdminMailer.email_updated_notification(
            admin,
            user,
            old_email
          ).deliver_later
        end

      redirect_to edit_user_path
    else
      flash[:error] = t(".link_expired")
      redirect_to edit_user_path
    end
  end

  # GET /user/discord_account_required?course_requiring_discord
  def discord_account_required
    authorize(current_user)

    @course_requiring_discord_account =
      if params[:course_requiring_discord].present? &&
           !current_user.discord_account_connected?
        course =
          current_user.courses.find_by(id: params[:course_requiring_discord])

        session[:course_requiring_discord] = course.id if course.present?
        course
      elsif session.key?(:course_requiring_discord)
        course =
          current_user.courses.find_by(id: session[:course_requiring_discord])

        session.delete(:course_requiring_discord)
        course
      end
  end

  # GET /user/standing
  def standing
    @presenter =
      Users::StandingPresenter.new(view_context, authorize(current_user))
  end
end
