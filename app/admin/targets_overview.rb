ActiveAdmin.register_page 'Targets Overview' do
  controller do
    skip_after_action :intercom_rails_auto_include

    def index
      load_targets
    end

    def load_targets
      @targets = params[:batch].present? ? Target.where(batch_id: params[:batch]) : Batch.last.targets
    end
  end

  menu parent: 'Targets'

  content do
    render 'target_templates_list'
  end
end
