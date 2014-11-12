ActiveAdmin.register_page "Dashboard" do
  controller do
    newrelic_ignore
  end

  page_action :users_count_total do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_USERS)
  end

  page_action :startups_count_total do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS)
  end

  page_action :startups_count_agreement_signed do
    render json: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_AGREEMENT_SIGNED)
  end

  page_action :startups_count_split do
    render json: [
      { name: 'Unready', data: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_UNREADY) },
      { name: 'Pending', data: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_PENDING) },
      { name: 'Approved', data: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_APPROVED) },
      { name: 'Rejected', data: Statistic.chartkick_parameter_by_date(Statistic::PARAMETER_COUNT_STARTUPS_REJECTED) }
    ]
  end

  page_action :startups_count_current_split do
    render json: Startup.current_startups_split
  end

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    div do
      render('statistics') if current_admin_user.admin_type != AdminUser::TYPE_EDITOR
    end

    h1 'Recent Changes'
    para "Total versions stored: #{PaperTrail::Version.count}"

    div(id: 'papertrail_changeset')  do
      h2 'Changeset as JSON'
      div(id: 'papertrail_changeset_pre')
    end

    table_for PaperTrail::Version.order('id desc').limit(20) do
      column('Item') { |v| v.item.nil? ? "Deleted #{v.item_type} ##{v.item_id}" : link_to("#{v.item_type} ##{v.item_id}", [:admin, v.item]) }
      column('Event') { |v| v.event }
      column('Modified at') { |v| v.created_at.to_s :long }
      column('Whodunnit') { |v| v.whodunnit }
      column('Changeset') { |v| button 'Show Changeset', changeset: v.changeset.to_json, class: 'papertrail_changeset' }
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
