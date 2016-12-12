ActiveAdmin.register_page 'Targets Overview' do
  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      load_targets
    end

    def load_targets
      batch = params[:batch].present? ? Batch.find_by(id: params[:batch]) : Batch.last
      @targets = []
      batch.program_weeks.order(:number).each do |week|
        week_targets = []
        week.target_groups.each do |target_groups|
          week_targets << target_groups.targets
        end
        week_targets.flatten!
        @targets << week_targets
      end
    end
  end

  menu parent: 'Targets'

  content do
    render 'target_templates_list'
  end
end
