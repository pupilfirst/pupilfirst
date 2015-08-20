ActiveAdmin.register Startup do
  filter :approval_status, as: :select, collection: proc { Startup.valid_approval_status_values}
  filter :name
  filter :email
  filter :website
  filter :registration_type, as: :select, collection: proc { Startup.valid_registration_types }
  filter :stage, as: :select, collection: proc { Startup.valid_stages }
  filter :team_size
  filter :team_size_blank, as: :boolean, label: 'Team size not set'
  filter :incubation_location, as: :select, collection: proc { Startup.valid_incubation_location_values }
  filter :incubation_location_blank, as: :boolean, label: 'Incubation location not selected'
  filter :agreement_sent
  filter :physical_incubatee
  filter :categories, collection: proc { Category.startup_category }
  filter :featured

  scope :all, default: true
  scope :without_founders
  scope :agreement_live
  scope :agreement_expired
  scope('Student Startups') { |scope| scope.student_startups.not_unready }

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    actions

    column :status do |startup|
      startup.approval_status.capitalize
    end

    column :agreement_sent
    column :name do |startup|
      link_to startup.name, startup, target: "_blank"
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

    column :website
    column :featured
  end

  csv do
    column :name
    column :incubation_location
    column :physical_incubatee
    column(:founders) { |startup| startup.founders.pluck(:fullname).join ', ' }
    column(:women_cofounders) { |startup| startup.founders.where(gender: User::GENDER_FEMALE).count }
    column :pitch
    column :website
    column :approval_status
    column :email
    column :registration_type
    column :about
    column :district
    column :pin
    column :cool_fact
    column :product_name
    column :product_progress
    column :product_description
    column :presentation_link
    column :revenue_generated
    column :team_size
    column :women_employees
    column :agreement_sent
    column :agreement_first_signed_at
    column :agreement_last_signed_at
    column :agreement_ends_at
  end

  member_action :custom_update, method: :put do
    startup = Startup.friendly.find params[:id]
    startup.update_attributes!(permitted_params[:startup])

    case params[:email_to_send].to_sym
      when :approval
        StartupMailer.startup_approved(startup).deliver_later
        push_message = 'Congratulations! Your request for incubation at Startup Village has been approved.'

      when :rejection
        StartupMailer.startup_rejected(startup).deliver_later
        push_message = "We're sorry, but your request for incubation at Startup Village has been rejected."
    end

    redirect_to action: :show
  end

  member_action :send_form_email, method: :post do
    startup = Startup.friendly.find params[:startup_id]
    push_message = 'Please complete the incubation process by following the steps in the Startup Village application!'

    StartupMailer.reminder_to_complete_startup_info(startup).deliver_later
    redirect_to action: :show
  end

  member_action :send_startup_profile_reminder, method: :post do
    startup = Startup.friendly.find params[:id]

    push_message = 'Please make sure you complete your startup profile to get noticed by mentors and investors.'

    StartupMailer.reminder_to_complete_startup_profile(startup).deliver_later

    redirect_to action: :show
  end

  show do |ad|
    attributes_table do
      row :status do |startup|
        startup.approval_status.capitalize
      end
      row :featured
      row :physical_incubatee
      row :agreement_sent
      row :agreement_first_signed_at
      row :agreement_last_signed_at
      row :agreement_ends_at
      row :email
      row :logo do |startup|
        link_to(image_tag(startup.logo_url(:thumb)), startup.logo_url)
      end
      row :stage
      row :website
      row :presentation_link do |startup|
        link_to startup.presentation_link, startup.presentation_link if startup.presentation_link.present?
      end
      row :revenue_generated
      row :team_size
      row :women_employees
      row :incubation_location
      row :about do |startup|
        simple_format startup.about
      end
      row :categories do |startup|
        startup.categories.map(&:name).join(', ')
      end
      row :phone do |startup|
        startup.admin.try(:phone)
      end
      row :address
      row :district
      row :state

      row 'PIN Code' do
        startup.pin
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
      row :cofounders do |startup|
        startup.founders.count
      end
      row :women_cofounders do |startup|
        startup.founders.where(gender: "female").count
      end
      row :registration_type
      row :approval_status
      row :address

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
    end

    panel 'Emails and Notifications' do
      link_to('Reminder to complete startup profile', send_startup_profile_reminder_admin_startup_path, method: :post, data: { confirm: 'Are you sure you wish to send notification and email?' })
    end
  end

  form :partial => 'admin/startups/form'

  permit_params :name, :website, :about, :email, :logo, :facebook_link, :twitter_link,
    { category_ids: [] }, { founder_ids: [] }, { founders_attributes: [:id, :fullname, :email, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password] },
    :created_at, :updated_at, :approval_status, :approval_status, :registration_type,
    :incubation_location, :agreement_sent, :agreement_first_signed_at, :agreement_last_signed_at, :agreement_duration,
    :physical_incubatee, :presentation_link, :slug, :featured
end

