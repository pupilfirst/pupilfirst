module AdmissionStats
  class ApplicantsByLocationService
    def load_stats
      level_zero_founders = Founder.level_zero
      location_wise_split = level_zero_founders.joins(:college).select('colleges.state_id').group('colleges.state_id').count
      location_wise_split.map { |state_id, count| [State.find(state_id).name, count] }.to_h.to_json
    end
  end
end
