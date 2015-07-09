ActiveAdmin.register Mentor do
  # menu parent: 'Mentoring'

  # controller do
  #   newrelic_ignore
  # end

  # csv do
  #   column :name
  #   column(:phone_number) { |mentor| mentor.user.phone }
  #   column(:phone_verified) { |mentor| mentor.user.phone_verified }
  #   column(:email) { |mentor| mentor.user.email }
  #   column(:email_verified) { |mentor| mentor.user.confirmed_at.present? }
  #   column :verified_at
  #   column(:availability) { |mentor| availability_as_string mentor.availability }
  #   column :company
  #   column :title
  #   column(:skills) { |mentor| mentor_skills_as_string(mentor.skills) }
  #   column :company_level
  # end

  # index do
  #   selectable_column
  #   actions

  #   column :name do |mentor|
  #     mentor.user.fullname
  #   end

  #   column :availability do |mentor|
  #     availability_as_string mentor.availability
  #   end

  #   column :company

  #   column :title do |mentor|
  #     mentor.user.title
  #   end

  #   column :verified_at
  # end

  # show do
  #   attributes_table do
  #     row :user

  #     row :name do |mentor|
  #       mentor.user.fullname
  #     end

  #     row :company

  #     row :title do |mentor|
  #       mentor.user.title
  #     end

  #     row :skills do |mentor|
  #       mentor_skills_as_string(mentor.skills)
  #     end

  #     row :availability do |mentor|
  #       availability_as_string(mentor.availability)
  #     end

  #     row :company_level

  #     row :verified? do |mentor|
  #       if mentor.verified?
  #         "Verified at #{mentor.verified_at}"
  #       else
  #         link_to 'Set mentor to verified', verify_admin_mentor_path, data: { confirm: 'Are you sure you want to verify this mentor?' }
  #       end
  #     end
  #   end
  # end

  # member_action :verify do
  #   mentor = Mentor.find params[:id]
  #   mentor.update(verified_at: Time.now)
  #   MentoringMailer.mentor_verified(mentor).deliver_later
  #   redirect_to admin_mentor_url, notice: 'Mentor verified'
  # end

  # form do |f|
  #   f.inputs 'Mentor' do
  #   f.input :user
  #   f.input :company
  #   f.input :days_available, collection: Mentor.valid_days_available
  #   f.input :time_available, collection: Mentor.valid_time_available
  #   f.input :company_level, collection: Startup.valid_product_progress_values
  #   f.input :verified_at, as: :date_select
  #   end
  #   f.actions
  # end



  # permit_params :user_id, :company, :days_available, :time_available, :company_level, :verified_at
end
