ActiveAdmin.register_page 'Admissions Dashboard' do
  menu parent: 'Admissions', label: 'Dashboard', priority: 0

  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      @startups_stage_split = AdmissionStats::StageSplitService.new.startups_split
      @applicants_by_location = AdmissionStats::ApplicantsByLocationService.new.load
      @applicants_by_reference = AdmissionStats::ApplicantsByReferenceService.new.load
      @last_day_stats = AdmissionStats::LastDayStatsService.new(params).load
    end
  end

  content do
    render 'admissions_dashboard'
  end
end
