ActiveAdmin.register_page 'Dashboard' do
  controller do
    def index
      @core_stats = Admin::CoreStatsService.new.stats
    end
  end

  menu priority: 1

  content do
    render 'dashboard'
  end
end
