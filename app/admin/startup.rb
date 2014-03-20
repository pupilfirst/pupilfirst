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
      startup.approval_status ? "Accepted" : "Pending"
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
          link_to director.fullname, [ :admin, director ]
        end
      end
    end
    column :founders do |startup|
      table_for startup.founders.order('id ASC') do
        column do |founder|
          link_to founder.fullname, [ :admin, founder ]
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

  member_action :send_form_email, method: :post do
    puts "sent email"
    # SENDEMAIL
    redirect_to action: :show
  end

  show do |ad|
    attributes_table do
      row :status do
        'Approved'
      end
      row :name
      row :email
      row :phone
      row :logo do |startup|
        link_to(image_tag(startup.logo_url(:thumb)), startup.logo_url)
      end
      row :directors do |startup|
        table_for startup.directors.order('id ASC') do
          column do |director|
            link_to director.fullname, [ :admin, director ]
          end
        end
      end
      row :founders do |startup|
        table_for startup.founders.order('id ASC') do
          column do |founder|
            link_to founder.fullname, [ :admin, founder ]
          end
        end
      end
      row :facebook_link
      row :twitter_link
      row :pitch do |startup|
        startup.pitch.truncate(50) rescue nil
      end
      row :website
      row :startup_status do |startup|
        if startup.approval_status
          'Approved'
        elsif startup.valid?
          link_to("Approve Startup", admin_startup_path(startup:{approval_status: true}), { method: :put })
        else
          link_to("Waiting Completion. Send email with form link.", send_form_email_admin_startup_path, { method: :post })
        end

      end
      row :incorporation_status do |startup|
        if startup.incorporation_status
          'Approved'
        elsif startup.incorporation_submited?
          link_to("Approve Incorporation", admin_startup_path(startup:{incorporation_status: true}), { method: :put })
        else
          'Waiting Submition'
        end

      end
      row :bank_status do |startup|
        if startup.bank_status
          'Approved'
        elsif startup.bank_details_submited?
          link_to("Approve Bank", admin_startup_path(startup:{bank_status: true}), { method: :put })
        else
          'Waiting Submition'
        end

      end
      row :sep_status do |startup|
        if startup.sep_status
          'Approved'
        elsif startup.sep_submited?
          link_to("Approve Sep", admin_startup_path(startup:{sep_status: true}), { method: :put })
        else
          'Waiting Submition'
        end

      end
    end
  end

  form :partial => "admin/startups/form"
  permit_params :name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, {category_ids: []}, {founder_ids: []}, {founders_attributes: [:id, :fullname, :email, :username, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password]}, :created_at, :updated_at, :approval_status, :incorporation_status, :bank_status, :sep_status

end
