ActiveAdmin.register_page "Dashboard" do
  controller do
    newrelic_ignore
  end

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
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
