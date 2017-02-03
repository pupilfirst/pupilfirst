module ActiveAdmin
  module AdmissionsDashboardHelper
    def selected_round_ids
      @selected_round_ids ||= params[:round].present? ? [ApplicationRound.find(params[:round]).id] : ApplicationRound.all.pluck(:id)
    end

    def multiple_rounds_selected?
      selected_round_ids.count > 1
    end
  end
end
