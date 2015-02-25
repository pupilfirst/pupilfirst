class MentoringController < ApplicationController
  before_filter :authenticate_user!, except: %w(index sign_up sign_up_form)
  before_filter(only: %w(new_step1 register)) { |c| c.send(:redirect_registration_steps, 1) }
  before_filter(only: %w(new_step2 register_2)) { |c| c.send(:redirect_registration_steps, 2) }
  before_filter(only: %w(new_step3 register_3)) { |c| c.send(:redirect_registration_steps, 3) }
  before_filter(only: %w(new_step4 register_4)) { |c| c.send(:redirect_registration_steps, 4) }

  # GET /mentoring
  def index
    @startups = Startup.paginate(page: params[:startups_page], per_page: 10)
    # @startups = Startup.agreement_live
    @mentors = Mentor.listed_mentors(exclude: current_user)
  end

  # GET /mentoring/register
  def new_step1
    @mentor = current_user.build_mentor
  end

  # POST /mentoring/register
  def register
    @mentor = current_user.build_mentor
    # @mentor = Mentor.new(mentor_params)

    if @mentor.update(mentor_params)
      redirect_to mentoring_register_2_url
    else
      render 'new_step1'
    end
  end

  # GET /mentoring/register_2
  def new_step2
    @skills = Category.mentor_skill_category
  end

  # POST /mentoring/register_2
  def register_2
    @skills = Category.mentor_skill_category
    mentor = current_user.mentor

    mentor.add_skill(params[:mentor_skill_1], params[:mentor_skill_1_expertise])
    mentor.add_skill(params[:mentor_skill_2], params[:mentor_skill_2_expertise])
    mentor.add_skill(params[:mentor_skill_3], params[:mentor_skill_3_expertise])

    if mentor.skills.count > 0
      redirect_to mentoring_register_3_url
    else
      @failed_to_create_skills = true

      render 'new_step2'
    end
  end

  # GET /mentoring/register_3
  def new_step3
  end

  # POST /mentoring/register_3
  def register_3
    # Generate a 6-digit verification code to send to the phone number.
    code, phone_number = begin
      current_user.generate_phone_number_verification_code(params[:mentor_phone_number])
    rescue Exceptions::InvalidPhoneNumber => e
      @failed_to_add_phone_number = e.message

      render 'new_step3' and return
    end

    # SMS the code to the phone number. Currently uses FA format.
    RestClient.post(APP_CONFIG[:sms_provider_url], text: "Verification code for SV Mentoring platform: #{code}", msisdn: phone_number)

    redirect_to mentoring_register_4_url
  end

  # GET /mentoring/register_4
  def new_step4
  end

  # POST /mentoring/register_4
  def register_4
    begin
      current_user.verify_phone_number(current_user.phone, params[:mentor_phone_verification_code])
    rescue Exceptions::PhoneNumberVerificationFailed
      @failed_to_verify_phone_number = true

      render 'new_step4' and return
    end

    flash[:notice] = 'You have successfully registered as a mentor!'

    redirect_to current_user
  end

  # GET /mentoring/sign_up
  def sign_up_form
    @user = User.new
  end

  # POST /mentoring/sign_up
  def sign_up
    @user = User.new user_params

    if @user.save
      Rails.llog.info event: :mentor_signup, email: @user.email
      flash[:notice] = 'Your SV account has been created. Please login with your SV ID and password.'
      redirect_to mentoring_url
    else
      render :sign_up_form
    end
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :email, :password, :password_confirmation)
  end

  def mentor_params
    params.require(:mentor).permit({ user_attributes: [:id, :fullname, :title] }, :company,
      :company_level, :days_available, :time_available
    )
  end

  def redirect_registration_steps(step)
    if current_user.mentor.present?
      if current_user.mentor.skills.present?
        if current_user.phone.present?
          if current_user.phone_verified?
            redirect_to current_user
          else
            redirect_to mentoring_register_4_url unless step == 4
          end
        else
          redirect_to mentoring_register_3_url unless step == 3
        end
      else
        redirect_to mentoring_register_2_url unless step == 2
      end
    else
      redirect_to mentoring_register_url unless step == 1
    end
  end
end
