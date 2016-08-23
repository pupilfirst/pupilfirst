module ActiveAdmin
  module AdmissionsDashboardHelper
    def paid_applicants_by_reference
      named_references = BatchApplicant.reference_sources - ['Other (Please Specify)']
      paid_applicants = BatchApplicant.where(reference: named_references).group(:reference).count
      paid_applicants_others_count = BatchApplicant.where.not(reference: named_references).count

      paid_applicants["Other"] = paid_applicants_others_count if paid_applicants_others_count > 0
      paid_applicants.to_json
    end
  end
end
