class FacultyController < ApplicationController
  # GET /faculty
  def index
    @skip_container = true
  end

  # POST /faculty/:id/connect
  def connect
    questions = params[:connect_request][:questions]
    faculty = Faculty.find(params[:id])
    connect_slot = faculty.connect_slots.find(params[:connect_request][:connect_slot])
    connect_request = connect_slot.build_connect_request(startup: current_user.startup, questions: questions)

    if connect_request.save
      flash[:success] = 'Connect Request has been submitted. You will receive an email once its confirmed.'
    else
      flash[:error] = 'Something went wrong while attempting to create connect request! :('
    end

    redirect_to faculty_index_path
  end

  # GET /faculty/:id/weekly_slots(token)
  def weekly_slots
    raise_not_found unless params[:token]
    @faculty = Faculty.find_by token: params[:token]
    raise_not_found unless @faculty
  end

end
