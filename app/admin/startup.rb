ActiveAdmin.register Startup do
  filter :approval_status, as: :select, collection: proc { Startup.valid_approval_status_values }
  filter :name
  filter :batch, as: :select, collection: (1..10)
  filter :website
  filter :registration_type, as: :select, collection: proc { Startup.valid_registration_types }
  filter :incubation_location, as: :select, collection: proc { Startup.valid_incubation_location_values }
  filter :categories, collection: proc { Category.startup_category }
  filter :featured

  scope :all, default: true
  scope :batched
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

    column :batch

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

    column :website

    column :karma_points do |startup|
      startup.karma_points.where('karma_points.created_at > ?', Date.today.beginning_of_week).sum(:points)
    end
  end

  csv do
    column :name
    column :batch
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
      when :rejection
        StartupMailer.startup_rejected(startup).deliver_later
    end

    redirect_to action: :show
  end

  member_action :send_form_email, method: :post do
    startup = Startup.friendly.find params[:startup_id]
    StartupMailer.reminder_to_complete_startup_info(startup).deliver_later
    redirect_to action: :show
  end

  member_action :send_startup_profile_reminder, method: :post do
    startup = Startup.friendly.find params[:id]
    StartupMailer.reminder_to_complete_startup_profile(startup).deliver_later
    redirect_to action: :show
  end

  show do
    attributes_table do
      row :approval_status do |startup|
        div class: 'startup-status' do
          if startup.unready?
            'Waiting for completion'
          else
            startup.approval_status
          end
        end

        div class: 'startup-status-buttons' do
          if startup.pending? || startup.rejected?
            span do
              button_to('Approve Startup',
                custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_APPROVED }, email_to_send: :approval),
                method: :put, data: { confirm: 'Are you sure?' })
            end

            unless startup.rejected?
              span do
                button_to('Reject Startup',
                  custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_REJECTED }, email_to_send: :rejection),
                  { method: :put, data: { confirm: 'Are you sure?' } })
              end
            end
          elsif startup.unready?
            span do
              button_to('Send reminder e-mail', send_form_email_admin_startup_path(startup_id: startup.id))
            end
          end
        end
      end

      row :batch
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
        startup.founders.each do |founder|
          div do
            span do
              link_to founder.fullname, [:admin, founder]
            end

            span do
              " &mdash; #{link_to 'Karma++'.html_safe, new_admin_karma_point_path(karma_point: { user_id: founder.id })}".html_safe
            end
          end
        end
      end

      row :women_cofounders do |startup|
        startup.founders.where(gender: User::GENDER_FEMALE).count
      end

      row :registration_type
      row :address
    end

    panel 'Feedback on Startup' do
      link_to('Record new feedback', new_admin_startup_feedback_path(startup_feedback: { startup_id: Startup.friendly.find(params[:id]).id, reference_url: startup_url(Startup.friendly.find(params[:id])) }))
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
    :physical_incubatee, :presentation_link, :slug, :featured, :batch
end

