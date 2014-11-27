class MentoringController < ApplicationController
  before_filter :authenticate_user!, except: %w(index sign_up sign_up_form)
  before_filter(only: %w(new_step1 register)) { |c| c.send(:redirect_registration_steps, 1) }
  before_filter(only: %w(new_step2 register_2)) { |c| c.send(:redirect_registration_steps, 2) }
  before_filter(only: %w(new_step3 register_3)) { |c| c.send(:redirect_registration_steps, 3) }

  # GET /mentoring
  def index
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
      flash[:notice] = 'Skills added!'

      redirect_to mentoring_url
    else
      @failed_to_create_skills = true

      render 'new_step2'
    end
  end

  # GET /mentoring/register_3
  def new_step3
    @skills = Category.mentor_skill_category
  end

  # GET /mentoring/sign_up
  def sign_up_form
    @user = User.new
  end

  # POST /mentoring/sign_up
  def sign_up
    @user = User.new user_params

    if @user.save
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
    params.require(:mentor).permit({ user_attributes: [:id, :fullname, :title] }, :company_id,
      :company_level, :cost_to_company, :time_donate_percentage, :days_available, :time_available
    )
  end

  def redirect_registration_steps(step)
    if current_user.mentor.present?
      if current_user.mentor.skills.present?
        if current_user.phone_verified?
          redirect_to mentoring_url
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
