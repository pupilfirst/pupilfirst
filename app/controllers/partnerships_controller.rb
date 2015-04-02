class PartnershipsController < ApplicationController
  before_filter :verify_confirmation_token, only: %w(show_confirmation submit_confirmation)

  # GET /partnerships/confirm/:confirmation_token
  def show_confirmation
    # @partnership loaded from #verify_confirmation_token
  end

  # POST /partnerships/confirm/:confirmation_token
  def submit_confirmation
    # @partnership loaded from #verify_confirmation_token

    # Update user data.
    if @partnership.user.update_partnership_fields(user_params)
      # Confirm the partnership for this user.
      @partnership.confirm!

      redirect_to partnerships_confirmation_success_url
      return
    end

    render :show_confirmation
  end

  def confirmation_success

  end

  private

  def user_params
    params.require(:user).permit(:fullname, :born_on,
      :current_occupation, :educational_qualification, :religion, :communication_address)
  end

  def verify_confirmation_token
    @partnership = Partnership.find_by confirmation_token: params[:confirmation_token]

    # Only allow confirmation if token is valid, and if partnership hasn't been confirmed already.
    raise_not_found unless @partnership.present?
    raise_not_found unless @partnership.confirmed_at.nil?
  end
end
