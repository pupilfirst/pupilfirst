ActiveAdmin.register_page "Dashboard" do
  controller do
    newrelic_ignore
  end

  page_action :users_count_total do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_USERS, from: params[:from], to: params[:to])
  end

  page_action :users_count_student_entrepreneurs do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_USERS_STUDENT_ENTREPRENEURS, from: params[:from], to: params[:to])
  end

  page_action :startups_count_total do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS, from: params[:from], to: params[:to])
  end

  page_action :startups_count_unready do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_UNREADY, from: params[:from], to: params[:to])
  end

  page_action :startups_count_current_split do
    render json: Startup.current_startups_split
  end

  menu :priority => 1, :label => proc{ I18n.t('active_admin.dashboard') }

  content :title => proc{ I18n.t('active_admin.dashboard') } do
    div do
      render 'statistics'
    end
  end
end
