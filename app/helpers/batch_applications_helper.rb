# encoding: utf-8

module BatchApplicationsHelper
  def next_stage_date
    current_stage.next.tentative_start_date(current_batch).strftime('%A, %b %e')
  end
end
