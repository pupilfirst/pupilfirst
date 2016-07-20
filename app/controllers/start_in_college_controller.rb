class StartInCollegeController < ApplicationController
  before_action :authorize_student, except: %w(index student_details create_student)
  before_action :block_student, only: %w(student_details create_student)
  before_action :lock_under_feature_flag, only: %w(chapter quiz quiz_submission)

  helper_method :current_mooc_student

  layout 'application_v2'

  # GET /startincollege
  #
  # Landing page for StartInCollege
  def index
  end

  # GET /startincollege/start
  #
  # Start page for the course.
  def start
    if current_mooc_student.present?
      @skip_container = true
    else
      redirect_to start_in_college_student_details_path
    end
  end

  # GET /startincollege/student_details
  #
  # Signup page for MOOC course.
  def student_details
    @skip_container = true
    @form = MoocStudentSignupForm.new(MoocStudent.new)
    @form.prepopulate! email: current_user&.email
    @disable_email = true if current_user.present?
  end

  # POST /startincollege/create_student
  def create_student
    @form = MoocStudentSignupForm.new(MoocStudent.new)

    if @form.validate(params[:mooc_student_signup])
      @user = @form.save(referer: start_in_college_start_url)
      @skip_container = true
      render 'user_sessions/send_email'
    else
      render 'student_details'
    end
  end

  # POST /startincollege/save_student_details
  #
  # Create MoocStudent and send user login email, or start course if already logged in.
  def save_student_details
    if current_mooc_student.update(update_params)
      flash[:success] = 'Your details have been saved!'
      redirect_to start_in_college_start_path
    else
      render 'student_details'
    end
  end

  # GET /startincollege/chapter/:id/:section_id
  #
  # Displays the content of a chapter's section.
  def chapter
    raise_not_found unless section_exists?

    render "start_in_college/chapters/chapter_#{params[:id]}_#{params[:section_id]}"
  end

  # GET /startincollege/quiz/:id
  #
  # Displays the quiz questions
  def quiz
    raise_not_found unless chapter_exists?

    @chapter = CourseChapter.find(params[:id])
    @questions = @chapter.quiz_questions.shuffle

    @form = QuizSubmissionForm.new(OpenStruct.new)
    @form.prepopulate! questions: @questions

    render "start_in_college/quizzes/quiz_#{params[:id]}"
  end

  # POST /startincollege/quiz_submission
  #
  # Evaluates a quiz submission
  def quiz_submission
    @chapter = CourseChapter.find params[:chapter]
    grade_submission
  end

  protected

  def current_mooc_student
    @current_mooc_student ||= MoocStudent.find_by(user: current_user) if current_user.present?
  end

  private

  def block_student
    return if current_mooc_student.blank?
    flash[:alert] = 'You have already registered for the course!'
    redirect_to start_in_college_start_path
  end

  def authorize_student
    request_authentication if current_mooc_student.blank?
  end

  def request_authentication
    redirect_to start_in_college_student_details_path
  end

  def update_params
    params.require(:mooc_student).permit(:name, :gender, :university_id, :college, :semester, :state)
  end

  def chapter_exists?
    params[:id].to_i.in? CourseChapter.valid_chapter_numbers
  end

  def chapter_has_section?
    params[:section_id].to_i <= CourseChapter.find(params[:id]).sections_count
  end

  def section_exists?
    chapter_exists? && chapter_has_section?
  end

  def lock_under_feature_flag
    raise_not_found unless feature_active? :start_in_college
  end

  def grade_submission
    answers = params[:quiz_submission][:questions_attributes].values

    @total = answers.count
    @attempted = answers.count{ |a| a[:answer_id].present? }
    @correct = answers.count{ |a| a[:answer_id].to_i == QuizQuestion.find(a[:id]).correct_answer.id }
  end
end
