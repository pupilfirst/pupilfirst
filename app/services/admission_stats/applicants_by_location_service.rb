module AdmissionStats
  class ApplicantsByLocationService
    def load
      location_wise_split = Founder.joins(:college).select('colleges.state_id').group('colleges.state_id').count
      location_wise_split.map { |state_id, count| [State.find(state_id).name, count] }.to_h.to_json
    end
  end
end
