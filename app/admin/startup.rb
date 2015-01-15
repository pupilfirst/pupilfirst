ActiveAdmin.register Startup do
  filter :approval_status, as: :select, collection: proc { Startup.valid_approval_status_values}
  filter :name
  filter :email
  filter :website
  filter :registration_type, as: :select, collection: proc { Startup.valid_registration_types }
  filter :product_name
  filter :product_progress, as: :select, collection: proc { Startup.valid_product_progress_values }
  filter :team_size
  filter :team_size_blank, as: :boolean, label: 'Team size not set'
  filter :incubation_location, as: :select, collection: proc { Startup.valid_incubation_location_values }
  filter :incubation_location_blank, as: :boolean, label: 'Incubation location not selected'
  filter :agreement_sent
  filter :physical_incubatee
  filter :categories, collection: proc { Category.startup_category }

  scope :all
  scope :without_founders
  scope :agreement_live

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
        StartupMailer.startup_approved(startup).deliver_now
        push_message = 'Congratulations! Your request for incubation at Startup Village has been approved.'

        startup.founders.each do |user|
          UserPushNotifyJob.new.async.perform(user.id, :startup_approval, push_message)
        end
      when :rejection
        StartupMailer.startup_rejected(startup).deliver_now
        push_message = "We're sorry, but your request for incubation at Startup Village has been rejected."

        startup.founders.each do |user|
          UserPushNotifyJob.new.async.perform(user.id, :startup_rejection, push_message)
        end
      when :incorporation
        StartupMailer.incorporation_approved(startup).deliver_now
      when :bank
        StartupMailer.bank_approved(startup).deliver_now
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

    StartupMailer.reminder_to_complete_startup_info(startup).deliver_now
    startup.founders.each { |user| user.update_attributes!({ startup_form_link_sent_status: true }) }
    redirect_to action: :show
  end

  member_action :send_startup_profile_reminder, method: :post do
    startup = Startup.find params[:id]

    push_message = 'Please make sure you complete your startup profile to get noticed by mentors and investors.'

    startup.founders.each do |user|
      UserPushNotifyJob.new.async.perform(user.id, :startup_profile_reminder, push_message)
    end

    StartupMailer.reminder_to_complete_startup_profile(startup).deliver_now

    redirect_to action: :show
  end

  member_action :generate_partnerships_pdf, method: :get do
    require 'prawn'
    require 'prawn/measurement_extensions'

    startup = Startup.find params[:id]

    generated_pdf = Prawn::Document.new do
      partners = startup.partnerships.order('id')
      users = User.joins(:partnerships).order('partnerships.id').where('partnerships.startup_id = ?', startup.id)
      data = [
        ['Partner Name'] + users.pluck(:fullname),
        ['Address'] + users.pluck(:communication_address),
        ['Gender'] + users.pluck(:gender).map { |g| g.try :capitalize },
        ['Date of Birth'] + users.pluck(:born_on).map { |bo| bo.try(:strftime, '%B %d, %Y') },
        ['PAN'] + users.pluck(:pan),
        ["Father's / Husband's Name"] + users.pluck(:father_or_husband_name),
        ['Current Occupation'] + users.pluck(:current_occupation).map { |co| co.blank? ? '-' : co.gsub('_', ' ').capitalize },
        ['Religion'] + users.pluck(:religion).map { |r| r.try :capitalize },
        ['Marital Status'] + users.pluck(:married).map { |m| m ? 'Married' : 'Single' },
        ['Educational Qualification'] + users.pluck(:educational_qualification).map { |eq| eq.blank? ? '-' : eq.gsub('_', ' ').capitalize },
        ['Salary (INR)'] + partners.pluck(:salary),
        ['Cash Contribution (INR)'] + partners.pluck(:cash_contribution),
        ['Managing Partner?'] + partners.pluck(:managing_partner).map { |mp| mp ? 'Yes' : 'No' },
        ['Eligible to operate bank account?'] + partners.pluck(:operate_bank_account).map { |oba| oba ? 'Yes' : 'No' },
        ['Operational limit on bank account'] + partners.pluck(:bank_account_operation_limit),
        ['Profit / Loss sharing percentage'] + partners.pluck(:share_percentage).map { |sp| "#{sp}%" },
        ['Email Address'] + users.pluck(:email),
        ['Phone Number'] + users.pluck(:phone)
      ]

      table(data, {
          row_colors: %w(EEEEEE FFFFFF),
          cell_style: {
            border_color: '999999'
          }
        }) do
        columns(0).background_color = 'EEEEEE'
        columns(0).font_style = :bold
        rows(0).background_color = 'CCCCCC'
        rows(0).font_style = :bold
      end

      move_down 5.mm
      text 'Partnership', style: :bold
      move_down 3.mm
      text "<strong>Name:</strong> #{startup.name}", inline_format: true
      move_down 3.mm
      text "<strong>Objective:</strong> #{startup.pitch}", inline_format: true
      move_down 3.mm
      text 'Address:', style: :bold
      text startup.address
    end.render

    send_data generated_pdf, filename: "#{startup.name}.pdf", type: 'application/pdf'
  end

  member_action :generate_bank_account_pdf, method: :get do
    require 'prawn'
    require 'prawn/measurement_extensions'

    startup = Startup.find params[:id]

    generated_pdf = Prawn::Document.new(
      {
        page_size: 'A4',
        margin: 0
      }
    ) do
      block_text_options_at = lambda { |x, y, spacing| { character_spacing: spacing, at: [((x / 1240.0) * 210.0).mm, ((((1754 - y) / 1754.0) * 297.0) + 2.2).mm] } }

      font 'Courier', size: 9

      # First page
      image Rails.root.join('files', 'image-1.jpg'), fit: [210.mm, 297.mm]
      text_box 'THIS IS A LONG BRANCH NAME', block_text_options_at.call(95, 208, 5.65)
      text_box 'THIS IS A FULL NAME', block_text_options_at.call(140, 762, 7.6)
      start_new_page

      # Second page
      image Rails.root.join('files', 'image-2.jpg'), fit: [210.mm, 297.mm]
      start_new_page

      # Third page
      image Rails.root.join('files', 'image-3.jpg'), fit: [210.mm, 297.mm]
      start_new_page

      # Fourth page
      image Rails.root.join('files', 'image-4.jpg'), fit: [210.mm, 297.mm]
    end.render

    send_data generated_pdf, filename: "#{startup.name}.pdf", type: 'application/pdf'
  end

  show do |ad|
    attributes_table do
      row :status do |startup|
        startup.approval_status.capitalize
      end
      row :physical_incubatee
      row :agreement_sent
      row :agreement_first_signed_at
      row :agreement_last_signed_at
      row :agreement_ends_at
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
      row :incubation_location
      row :about do |startup|
        simple_format startup.about
      end
      row :categories do |startup|
        startup.categories.map(&:name).join(', ')
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
      startup.partnerships.order('share_percentage DESC').each do |partner|
        div(class: 'admin_startup_partnership') do
          attributes_table_for partner do
            row :user do
              link_to partner.user.fullname, [:admin, partner.user]
            end
            [:share_percentage, :salary, :cash_contribution, :managing_partner, :operate_bank_account].each do |column|
              row column
            end
          end
        end
      end

      div class: 'clear-both'

      div { link_to 'Manage these entries in Partnership section.', admin_partnerships_path(q: { startup_id_eq: startup.id }) }
      div { link_to 'Download partnership details as PDF', generate_partnerships_pdf_admin_startup_path }
      # div { link_to 'Download bank account opening form as PDF', generate_bank_account_pdf_admin_startup_path }
    end if startup.partnerships.present?

    panel 'Emails and Notifications' do
      link_to('Reminder to complete startup profile', send_startup_profile_reminder_admin_startup_path, method: :post, data: { confirm: 'Are you sure you wish to send notification and email?' })
    end
  end

  form :partial => "admin/startups/form"
  permit_params :name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, :cool_fact,
    { category_ids: [] }, { founder_ids: [] }, { founders_attributes: [:id, :fullname, :email, :username, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password] },
    :created_at, :updated_at, :approval_status, :incorporation_status, :bank_status, :sep_status, :dsc,
    :authorized_capital, :share_holding_pattern, :moa, :police_station, :approval_status, :incorporation_status,
    :bank_status, :sep_status, :company_names, :address, :pre_funds, :startup_before, :product_name,
    :product_description, :registration_type, :incubation_location, { help_from_sv: [] }, :agreement_sent,
    :agreement_first_signed_at, :agreement_last_signed_at, :agreement_duration, :physical_incubatee
end
