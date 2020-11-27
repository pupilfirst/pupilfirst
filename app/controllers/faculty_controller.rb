class FacultyController < ApplicationController
  before_action :validate_faculty, only: %i[weekly_slots save_weekly_slots mark_unavailable slots_saved]

  # GET /faculty, GET /coaches
  def index
    @coaches = policy_scope(Faculty).includes(:faculty_course_enrollments, user: { avatar_attachment: :blob })

    raise_not_found unless @coaches.exists?

    render 'index', layout: 'student'
  end

  # GET /coaches/:id
  def show
    index
  end

  # GET /faculty/weekly_slots/:token
  def weekly_slots
    @slot_list = create_slot_list_for @faculty
  end

  # POST /faculty/save_weekly_slots/:token
  def save_weekly_slots
    list_of_slots = JSON.parse(params[:list_of_slots])
    save_slots_in_list list_of_slots, @faculty
    flash[:success] = 'Your slots have been saved succesfully!'
    redirect_to action: 'slots_saved'
  end

  # DELETE /faculty/weekly_slots/:token
  def mark_unavailable
    @faculty.connect_slots.next_week.destroy_all
    flash[:success] = 'Your have been marked unavailable for next week!'
    redirect_to action: 'slots_saved'
  end

  # GET /faculty/slots_saved/:token
  def slots_saved
    # There's nothing to load.
  end

  private

  def validate_faculty
    @faculty = Faculty.find_by token: params[:token]
    raise_not_found if @faculty&.email.blank?
  end

  def save_slots_in_list(list, faculty)
    start_date = 7.days.from_now.beginning_of_week.to_date

    # Reset next week slots to empty, while preserving slots with connect requests.
    faculty.connect_slots.includes(:connect_request).where(connect_requests: { id: nil }).next_week.destroy_all

    list.each_key do |day|
      day_number = day.to_i

      list[day].each do |slot|
        time = slot['time'] # From value

        date = start_date + day_number - 1 # index of dates start at 1
        hour = time.to_i
        minute = ((time.to_f - hour) * 60).to_s.delete('.')[0..1]

        # Save submitted week slots
        ConnectSlot.create(
          faculty: faculty, slot_at: Time.parse("#{date} #{hour.to_s.rjust(2, '0')}:#{minute}:00 +0530")
        )
      end
    end
  end

  def create_slot_list_for(faculty)
    slots = faculty.connect_slots.next_week

    slots.each_with_object({}) do |slot, list_of_slots|
      day = (slot.slot_at.to_date - 7.days.from_now.beginning_of_week.to_date).to_i + 1
      list_of_slots[day] ||= []
      time = slot.slot_at.hour + slot.slot_at.min.to_f / 60
      list_of_slots[day] << { 'time' => time, 'requested' => slot.connect_request.present? }
    end.to_json
  end
end
