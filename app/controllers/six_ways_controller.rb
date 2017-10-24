class SixWaysController < ApplicationController
  before_action :authorize_student, only: %w[completion_certificate]
  before_action :block_student, only: %w[student_details create_student]
  before_action :gtu_variables, only: %w[gtu_index]

  helper_method :quiz_score

  layout 'application_v2'

  # GET /sixways
  #
  # Landing page for sixways
  def index
    # There's nothing to load.
  end

  # GET /sixways/start
  #
  # Start page for the course.
  def start
    @skip_container = true
  end

  # Landing page for GTU MOOC
  def gtu_index
    # There's nothing to load.
  end

  # GET /sixways/student_details
  #
  # Signup page for MOOC course.
  def student_details
    @skip_container = true
    @form = MoocStudentSignupForm.new(MoocStudent.new)
    @form.prepopulate! email: current_user&.email
    @disable_email = true if current_user.present?
  end

  # POST /sixways/create_student
  def create_student
    @form = MoocStudentSignupForm.new(MoocStudent.new)

    # Override the supplied email if user is already logged in.
    params[:mooc_student_signup][:email] = current_user.email if current_user.present?

    if @form.validate(params[:mooc_student_signup])
      @user = @form.save(send_sign_in_email: current_user.blank?)

      if current_user.present?
        redirect_to six_ways_start_url
      else
        @skip_container = true
        render 'users/sessions/send_login_email'
      end
    else
      render 'student_details'
    end
  end

  # POST /sixways/save_student_details
  #
  # Create MoocStudent and send user login email, or start course if already logged in.
  def save_student_details
    if current_mooc_student.update(update_params)
      flash[:success] = 'Your details have been saved!'
      redirect_to six_ways_start_path
    else
      render 'student_details'
    end
  end

  # GET /sixways/:module_name/:chapter_name
  #
  # Displays the content of a module's chapter.
  def module
    raise_not_found unless chapter_exists?
    @skip_container = true
    @module = CourseModule.friendly.find(params[:module_name])
    @chapter = @module.module_chapters.find_by(slug: params[:chapter_name])

    # mark this chapter as complete for the current student
    current_mooc_student.add_completed_chapter(@chapter) if current_mooc_student.present?

    render layout: 'sixways'
  end

  # GET /sixways/quiz/:module_name
  #
  # Displays the quiz questions
  def quiz
    raise_not_found unless module_exists?
    @skip_container = true
    @module = CourseModule.friendly.find(params[:module_name])
    @questions = @module.mooc_quiz_questions

    @form = QuizSubmissionForm.new(Reform::OpenForm.new)
    @form.prepopulate! questions: @questions
    render layout: 'sixways'
  end

  # POST /sixways/quiz_submission
  #
  # Evaluates a quiz submission
  def quiz_submission
    @skip_container = true
    @module = CourseModule.friendly.find params[:module]

    grade_submission
    save_grade if current_mooc_student.present?
    render layout: 'sixways'
  end

  # GET /sixways/course_end
  #
  # End of course page. Probably show grade and option to print certificate
  def course_end
    @skip_container = true
    @final_score = current_mooc_student.score.round if current_mooc_student.present?
  end

  # GET /sixways/completion_certificate
  #
  # Display the completion certificate as a pdf
  def completion_certificate
    respond_to do |format|
      format.pdf do
        pdf = MoocStudents::CompletionCertificate.new(current_mooc_student).build
        send_data pdf.render, type: 'application/pdf', filename: 'sixways_completion_certificate.pdf', disposition: 'inline'
      end
    end
  end

  private

  def block_student
    return if current_mooc_student.blank?
    flash[:alert] = 'You have already registered for the course!'
    redirect_to six_ways_start_path
  end

  def authorize_student
    request_authentication if current_mooc_student.blank?
  end

  def request_authentication
    redirect_to six_ways_student_details_path
  end

  def update_params
    params.require(:mooc_student).permit(:name, :gender, :college_id, :semester, :state)
  end

  def module_exists?
    CourseModule.friendly.find(params[:module_name]).present?
  end

  def module_has_chapter?
    params[:chapter_name].in? CourseModule.friendly.find(params[:module_name]).module_chapters.pluck(:slug)
  end

  def chapter_exists?
    module_exists? && module_has_chapter?
  end

  def grade_submission
    answers = params[:quiz_submission][:questions_attributes].values

    @total = answers.count
    @attempted = answers.count { |a| a[:answer_id].present? }
    @correct = answers.count { |a| a[:answer_id].to_i == MoocQuizQuestion.find(a[:id]).correct_answer.id }
  end

  def quiz_score
    ((@correct.to_f / @total) * 100).round
  end

  def save_grade
    QuizAttempt.create!(course_module: @module, mooc_student: current_mooc_student, score: quiz_score, attempted_questions: @attempted, total_questions: @total)
  end

  def gtu_variables
    @skip_container = true
    @hide_layout_header = true
    @hide_layout_footer = true
  end
end
