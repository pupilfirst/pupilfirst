module AdmissionStats
  class ApplicantsByReferenceService
    def load(stage)
      startups = stage.present? ? Startup.where(admission_stage: stage) : Startup.all

      named_references = Founder.reference_sources - ['Other (Please Specify)']
      founders_with_named_reference = Founder.where(reference: named_references, startup: startups).group(:reference).count
      founders_with_other_reference = Founder.where(startup: startups).where.not(reference: named_references).count

      stats = if founders_with_other_reference.positive?
        founders_with_named_reference.merge('Other' => founders_with_other_reference)
      else
        founders_with_named_reference
      end.to_json
      stats
    end
  end
end
