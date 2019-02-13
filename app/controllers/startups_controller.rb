class StartupsController < ApplicationController
  # POST /startup/level_up
  def level_up
    authorize current_startup

    Startups::LevelUpService.new(current_startup).execute
    redirect_to(student_dashboard_path(from: 'level_up', from_level: current_startup.level.number - 1))
  end
end
