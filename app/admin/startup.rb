ActiveAdmin.register Startup do
  # remove_filter :startups_categories
  # remove_filter :versions
  menu :parent => 'Startup'

  filter :approval_status, as: :select, collection: Startup.valid_approval_status_values
  filter :name
  filter :email
  filter :website
  filter :registration_type, as: :select, collection: Startup.valid_registration_types
  filter :product_name
  filter :product_progress, as: :select, collection: Startup.valid_product_progress_values
  filter :team_size
  filter :incubation_location_blank, as: :boolean, label: 'Incubation location not selected'
  filter :incubation_location, as: :select, collection: Startup.valid_incubation_location_values
  filter :agreement_sent
  filter :categories

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  controller do
    newrelic_ignore
  end

  index do
    actions
    column :status do |startup|
      startup.approval_status.capitalize
    end
    column :agreement_sent
    column :name
    column :presentation_link do |startup|
      link_to startup.presentation_link, startup.presentation_link if startup.presentation_link.present?
    end
    column :founders do |startup|
      table_for startup.founders.order('id ASC') do
        column do |founder|
          link_to founder.fullname, [:admin, founder]
        end
      end
    end

    column :categories do |startup|
      startup.categories.pluck(:name).join ', '
    end
    # column :facebook_link
    # column :twitter_link
    # column :pitch do |startup|
    #   startup.pitch.truncate(50) rescue nil
    # end
    column :website
  end

  member_action :custom_update, method: :put do
    startup = Startup.find params[:id]
    startup.update_attributes!(permitted_params[:startup])

    case params[:email_to_send].to_sym
      when :approval
        StartupMailer.startup_approved(startup).deliver
        push_message = 'Congratulations! Your request for incubation at Startup Village has been approved.'

        startup.founders.each do |user|
          UserPushNotifyJob.new.async.perform(user.id, :startup_approval, push_message)
        end
      when :rejection
        StartupMailer.startup_rejected(startup).deliver
        push_message = "We're sorry, but your request for incubation at Startup Village has been rejected."

        startup.founders.each do |user|
          UserPushNotifyJob.new.async.perform(user.id, :startup_rejection, push_message)
        end
      when :incorporation
        StartupMailer.incorporation_approved(startup).deliver
      when :bank
        StartupMailer.bank_approved(startup).deliver
      when :sep
    end

    redirect_to action: :show
  end

  member_action :send_form_email, method: :post do
    startup = Startup.find params[:startup_id]
    push_message = 'Please complete the incubation process by following the steps in the Startup Village application!'

    startup.founders.each do |user|
      UserPushNotifyJob.new.async.perform(user.id, :startup_approval, push_message)
    end

    StartupMailer.reminder_to_complete_startup_info(startup).deliver
    startup.founders.each { |user| user.update_attributes!({ startup_form_link_sent_status: true }) }
    redirect_to action: :show
  end

  show do |ad|
    attributes_table do
      row :status do |startup|
        startup.approval_status.capitalize
      end
      row :agreement_sent
      row :email
      row :phone
      row :logo do |startup|
        link_to(image_tag(startup.logo_url(:thumb)), startup.logo_url)
      end
      row :pitch
      row :website
      row :presentation_link do |startup|
        link_to startup.presentation_link, startup.presentation_link if startup.presentation_link.present?
      end
      row :product_progress
      row :revenue_generated
      row :team_size
      row :women_employees
      row :cool_fact
      row :address
      row :incubation_location
      row :about do |startup|
        simple_format startup.about
      end
      row :categories do |startup|
        startup.categories.map(&:name).join(', ')
      end
      row :facebook_link
      row :twitter_link
      row :founders do |startup|
        table_for startup.founders.order('id ASC') do
          column do |founder|
            link_to founder.fullname, [:admin, founder]
          end
        end
      end
      row :registration_type
      row :dsc
      row :authorized_capital
      row :share_holding_pattern
      row :moa
      row :police_station
      row :approval_status
      row :incorporation_status
      row :bank_status
      row :sep_status
      row :company_names
      row :address
      row :pre_funds
      row :startup_before
      row :help_from_sv
      row :product_name
      row :product_description

      row :startup_status do |startup|
        if startup.pending?
          "#{link_to('Approve Startup',
            custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_APPROVED }, email_to_send: :approval),
            { method: :put, data: { confirm: 'Are you sure?' } })} / #{
          link_to('Reject Startup',
            custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_REJECTED }, email_to_send: :rejection),
            { method: :put, data: { confirm: 'Are you sure?' } })}".html_safe
        elsif startup.unready?
          link_to('Waiting for Completion. Send reminder e-mail with links to mobile applications.',
            send_form_email_admin_startup_path(startup_id: startup.id),
            { method: :post })
        else
          startup.approval_status.capitalize
        end
      end

      row :incorporation_status do |startup|
        if startup.incorporation_status
          'Approved'
        elsif startup.incorporation_submited?
          link_to("Approve Incorporation",
            custom_update_admin_startup_path(startup: { incorporation_status: true }, email_to_send: :incorporation),
            { method: :put, data: { confirm: "Are you sure?" } })
        else
          'Waiting for Submission'
        end
      end

      row :bank_status do |startup|
        if startup.bank_status
          'Approved'
        elsif startup.bank_details_submited?
          link_to("Approve Bank",
            custom_update_admin_startup_path(startup: { bank_status: true }, email_to_send: :bank),
            { method: :put, data: { confirm: "Are you sure?" } })
        else
          'Waiting for Submission'
        end
      end

      row :sep_status do |startup|
        if startup.sep_status
          'Approved'
        elsif startup.sep_submited?
          link_to("Approve Sep",
            custom_update_admin_startup_path(startup: { sep_status: true }, email_to_send: :sep),
            { method: :put, data: { confirm: "Are you sure?" } })
        else
          'Waiting for Submission'
        end
      end
    end

    panel 'Partnership Details' do
      startup.partnerships.order('shares DESC').each do |partner|
        div(class: 'admin_startup_partnership') do
          attributes_table_for partner do
            row :user do
              link_to partner.user.fullname, [:admin, partner.user]
            end
            [:shares, :share_percentage, :salary, :cash_contribution, :managing_director, :operate_bank_account].each do |column|
              row column
            end
          end
        end
      end

      div class: 'clear-both'
    end
  end

  form :partial => "admin/startups/form"
  permit_params :name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, :cool_fact,
    { category_ids: [] }, { founder_ids: [] }, { founders_attributes: [:id, :fullname, :email, :username, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password] },
    :created_at, :updated_at, :approval_status, :incorporation_status, :bank_status, :sep_status, :dsc,
    :authorized_capital, :share_holding_pattern, :moa, :police_station, :approval_status, :incorporation_status,
    :bank_status, :sep_status, :company_names, :address, :pre_funds, :startup_before, :product_name,
    :product_description, :registration_type, :incubation_location, { help_from_sv: [] }, :agreement_sent
end
