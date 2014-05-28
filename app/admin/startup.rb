ActiveAdmin.register Startup do
  menu :parent => "Startup"

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
    column :name
    column :email
    column :phone
    column :logo do |startup|
      link_to(image_tag(startup.logo_url(:thumb)), startup.logo_url)
    end
    column :directors do |startup|
      table_for startup.directors.order('id ASC') do
        column do |director|
          link_to director.fullname, [:admin, director]
        end
      end
    end
    column :founders do |startup|
      table_for startup.founders.order('id ASC') do
        column do |founder|
          link_to founder.fullname, [:admin, founder]
        end
      end
    end
    column :facebook_link
    column :twitter_link
    column :pitch do |startup|
      startup.pitch.truncate(50) rescue nil
    end
    column :website

  end

  member_action :custom_update, method: :put do
    startup = Startup.find params[:id]
    if startup.update_attributes(permitted_params[:startup])
      case params[:email_to_send].to_sym
        when :approval
          StartupMailer.startup_approved(startup).deliver
          push_message = 'Congratulations! Your request for incubation at Startup Village has been approved.'

          startup.founders.each do |user|
            UserPushNotifyJob.new.async.perform(user.id, :startup_approval, push_message)
          end
        when :incorporation
          StartupMailer.incorporation_approved(startup).deliver
        when :bank
          StartupMailer.bank_approved(startup).deliver
        when :sep
      end
      redirect_to action: :show
    else
      render :update
    end
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
      row :name
      row :email
      row :phone
      row :logo do |startup|
        link_to(image_tag(startup.logo_url(:thumb)), startup.logo_url)
      end
      row :pitch
      row :address
      row :website
      row :about
      row :categories do |startup|
        startup.categories.map &:name
      end
      row :facebook_link
      row :twitter_link
      row :directors do |startup|
        table_for startup.directors.order('id ASC') do
          column do |director|
            link_to director.fullname, [:admin, director]
          end
        end
      end
      row :founders do |startup|
        table_for startup.founders.order('id ASC') do
          column do |founder|
            link_to founder.fullname, [:admin, founder]
          end
        end
      end
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

      row :startup_status do |startup|
        if startup.approved?
          'Approved'
        elsif startup.pending?
          link_to('Approve Startup',
            custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_APPROVED }, email_to_send: :approval),
            { method: :put, data: { confirm: 'Are you sure?' } })
        elsif startup.unready?
          link_to('Waiting for Completion. Send reminder e-mail with links to mobile applications.',
            send_form_email_admin_startup_path(startup_id: startup.id),
            { method: :post })
        else
          'Rejected'
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
  end

  form :partial => "admin/startups/form"
  permit_params :name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, { category_ids: [] }, { founder_ids: [] }, { founders_attributes: [:id, :fullname, :email, :username, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password] }, :created_at, :updated_at, :approval_status, :incorporation_status, :bank_status, :sep_status, :dsc, :authorized_capital, :share_holding_pattern, :moa, :police_station, :approval_status, :incorporation_status, :bank_status, :sep_status, :company_names, :address, :pre_funds, :startup_before, help_from_sv: []
end
