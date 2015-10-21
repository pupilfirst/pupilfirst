ActiveAdmin.register Startup do
  filter :approval_status, as: :select, collection: proc { Startup.valid_approval_status_values }
  filter :product_name
  filter :name
  filter :batch, as: :select, collection: (1..10)
  filter :stage, as: :select, collection: proc { stages_collection }
  filter :website
  filter :registration_type, as: :select, collection: proc { Startup.valid_registration_types }
  filter :incubation_location, as: :select, collection: proc { Startup.valid_incubation_location_values }
  filter :startup_categories
  filter :featured

  scope :approved, default: true
  scope :batched
  scope :all

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    selectable_column
    column :product_name

    column :status do |startup|
      startup.approval_status.capitalize
    end

    column :targets do |startup|
      ol do
        startup.targets.order('updated_at DESC').limit(5).each do |target|
          fa_icon = if target.done?
            'fa-check'
          elsif target.expired?
            'fa-times'
          else
            'fa-circle-o'
          end
          li do
            link_to " #{target.title}", [:admin, target], class: "fa #{fa_icon} no-text-decoration"
          end
        end
      end
    end

    column :timeline_events do |startup|
      ol do
        startup.timeline_events.order('updated_at DESC').limit(5).each do |event|
          fa_icon = if event.verified?
            'fa-check'
          elsif event.needs_improvement?
            'fa-times'
          else
            'fa-circle-o'
          end
          li do
            link_to " #{event.timeline_event_type.title}", [:admin, event], class: "fa #{fa_icon} no-text-decoration"
          end
        end
      end
    end

    actions do |startup|
      link_to('View Timeline', startup, target: '_blank') +
        link_to(
          'View All Feedback',
          admin_startup_feedback_index_url(
            'q[startup_id_eq]' => startup.id,
            commit: 'Filter'
          )
        ) +
        link_to(
          'Record New Feedback',
          new_admin_startup_feedback_path(
            startup_feedback: {
              startup_id: startup.id,
              reference_url: startup_url(startup)
            }
          )
        )
    end
  end

  csv do
    column :product_name
    column :product_description
    column :presentation_link
    column :product_video
    column :wireframe_link
    column :prototype_link
    column :name
    column :batch
    column :incubation_location
    column :physical_incubatee
    column(:founders) { |startup| startup.founders.pluck(:first_name).join ', ' }
    column(:women_cofounders) { |startup| startup.founders.where(gender: User::GENDER_FEMALE).count }
    column :pitch
    column :website
    column :approval_status
    column :email
    column :registration_type
    column :district
    column :pin
    column :cool_fact
    column :product_progress
    column :revenue_generated
    column :team_size
    column :women_employees
    column :agreement_sent
    column :agreement_first_signed_at
    column :agreement_last_signed_at
    column :agreement_ends_at
  end

  action_item :view_feedback, only: :show do
    link_to(
      'View All Feedback',
      admin_startup_feedback_index_url('q[startup_id_eq]' => Startup.friendly.find(params[:id]).id, commit: 'Filter')
    )
  end

  action_item :record_feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: Startup.friendly.find(params[:id]).id,
          reference_url: startup_url(Startup.friendly.find(params[:id]))
        }
      )
    )
  end

  action_item :view_timeline, only: :show do
    link_to('View Timeline', startup_url(startup), target: '_blank')
  end

  member_action :custom_update, method: :put do
    startup = Startup.friendly.find params[:id]
    startup.update_attributes!(permitted_params[:startup])

    case params[:email_to_send].to_sym
      when :approval
        StartupMailer.startup_approved(startup).deliver_later
      when :rejection
        StartupMailer.startup_rejected(startup).deliver_later
      when :dropped_out
        StartupMailer.startup_dropped_out(startup).deliver_later
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

  member_action :get_all_startup_feedback do
    startup = Startup.friendly.find params[:id]
    feedback = startup.startup_feedback.order('updated_at desc')

    respond_to do |format|
      format.json do
        render json: { feedback: feedback, product_name: startup.product_name }
      end
    end
  end

  member_action :change_admin, method: :patch do
    Startup.friendly.find(params[:id]).admin.update(startup_admin: nil)
    User.find(params[:founder_id]).update(startup_admin: true)
    redirect_to action: :show
  end

  show title: :product_name do
    attributes_table do
      row :product_description do |startup|
        simple_format startup.product_description
      end

      row :name
      row :legal_registered_name
      row :approval_status do |startup|
        div class: 'startup-status' do
          if startup.unready?
            'Waiting for completion'
          else
            startup.approval_status
          end
        end

        div class: 'startup-status-buttons' do
          unless startup.approved? || startup.unready?
            span do
              button_to(
                'Approve Startup',
                custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_APPROVED }, email_to_send: :approval),
                method: :put, data: { confirm: 'Are you sure you want to approve this startup?' }
              )
            end
          end
          unless startup.rejected? || startup.unready?
            span do
              button_to(
                'Reject Startup',
                custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_REJECTED }, email_to_send: :rejection),
                method: :put, data: { confirm: 'Are you sure you want to reject this startup?' }
              )
            end
          end
          unless startup.dropped_out?
            span do
              button_to(
                'Drop-out Startup',
                custom_update_admin_startup_path(startup: { approval_status: Startup::APPROVAL_STATUS_DROPPED_OUT }, email_to_send: :dropped_out),
                method: :put, data: { confirm: 'Are you sure you want to drop out this startup?' }
              )
            end
          end
          if startup.unready?
            span do
              button_to('Send reminder e-mail', send_form_email_admin_startup_path(startup_id: startup.id))
            end
          end
        end
      end

      row :batch
      row :iteration
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

      row :product_video do |startup|
        link_to startup.product_video, startup.product_video if startup.product_video.present?
      end

      row :wireframe_link do |startup|
        link_to startup.wireframe_link, startup.wireframe_link if startup.wireframe_link.present?
      end

      row :prototype_link do |startup|
        link_to startup.prototype_link, startup.prototype_link if startup.prototype_link.present?
      end

      row :revenue_generated
      row :team_size
      row :women_employees
      row :incubation_location

      row :startup_categories do |startup|
        startup.startup_categories.map(&:name).join(', ')
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

            span do
              if founder.startup_admin?
                " &mdash; (Current Team Lead)".html_safe
              else
                " &mdash; #{link_to('Make Team Lead', change_admin_admin_startup_path(founder_id: founder),
                  method: :patch, data: { confirm: 'Are you sure you want to change the team lead for this startup?' })}".html_safe
              end
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

    panel 'Emails and Notifications' do
      link_to(
        'Reminder to complete startup profile',
        send_startup_profile_reminder_admin_startup_path,
        method: :post, data: { confirm: 'Are you sure you wish to send notification and email?' }
      )
    end
  end

  form partial: 'admin/startups/form'

  permit_params :name, :product_name, :product_description, :legal_registered_name, :website, :email, :logo, :facebook_link, :twitter_link,
    { startup_category_ids: [] }, { founder_ids: [] },
    { founders_attributes: [:id, :first_name, :last_name, :email, :avatar, :remote_avatar_url, :linkedin_url, :twitter_url, :skip_password] },
    :created_at, :updated_at, :approval_status, :approval_status, :registration_type,
    :incubation_location, :agreement_sent, :agreement_first_signed_at, :agreement_last_signed_at, :agreement_duration,
    :physical_incubatee, :presentation_link, :product_video, :wireframe_link, :prototype_link, :slug, :featured, :batch
end
