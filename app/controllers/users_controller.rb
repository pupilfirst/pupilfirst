class UsersController < ApplicationController
  before_action :authenticate_user!, except: :delete_account
  layout 'student'

  # GET /dashboard/
  def dashboard
    @user = authorize(current_user)
  end

  def edit
    @user = authorize(current_user)
  end

  # GET /users/delete_account
  def delete_account
    user =
      Users::ValidateDeletionTokenService.new(params[:token], current_school)
        .authenticate
    if user.present?
      sign_in user
      @token = params[:token]
    else
      flash[:error] = t('.link_expired')
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
      render 'edit'
    end
  end

  # GET /user/update_email
  def update_email
    user =
      Users::ValidateUpdateEmailTokenService.new(params[:token], current_school)
        .authenticate

    if user.present? && user.new_email.present?
      old_email = user.email
      new_email = user.new_email

      # Update user email
      user.update!(email: new_email, update_email_token: nil, new_email: nil)

      # Create audit record
      AuditRecord.create!(
        audit_type: AuditRecord::TYPE_UPDATE_EMAIL,
        school_id: current_school.id,
        metadata: {
          user_id: current_user.id,
          email: new_email,
          old_email: old_email
        }
      )

      # Send success email to user
      UserMailer.confirm_email_update(user.name, user.email, current_school)
        .deliver_now

      # Send notification email to admins
      current_school
        .school_admins
        .where.not(user_id: user.id)
        .each do |admin|
          SchoolAdminMailer.email_updated_notification(admin, user, old_email)
            .deliver_later
        end

      redirect_to edit_user_path
    else
      flash[:error] = t('.link_expired')
      redirect_to edit_user_path
    end
  end
end
