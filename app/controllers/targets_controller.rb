class TargetsController < ApplicationController
  include CamelizeKeys
  include StringifyIds
  include DiscordAccountRequirable

  before_action :preview_or_authenticate
  before_action :require_discord_account, only: %i[show]

  # GET /targets/:id/(:slug)
  def show
    @presenter = Targets::ShowPresenter.new(view_context, @target)
    render "courses/curriculum", layout: "student_course"
  end

  # GET /targets/:id/details
  def details_v2
    student =
      current_user
        .students
        .joins(:course)
        .where(courses: { id: @course.id })
        .first if current_user.present?

    render json:
             camelize_keys(
               stringify_ids(
                 Targets::DetailsService.new(
                   @target,
                   student,
                   public_preview: current_user.blank?
                 ).details
               )
             )
  end

  def mark_as_read
    student =
      current_user
        .students
        .joins(:course)
        .where(courses: { id: course.id })
        .first if current_user.present?
    page_read = PageRead.new(target: @target, student_id: student.id)
    if page_read.save
      render json: page_read, status: :created
    else
      render json: page_read.errors, status: :unprocessable_entity
    end
  end

  private

  def course
    @course ||= Target.find(params[:id]).course
  end

  def preview_or_authenticate
    target = Target.find(params[:id])
    @course = target.course

    authenticate_user! unless @course.public_preview?

    @target = authorize(target)
  end
end
