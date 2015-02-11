ActiveAdmin.register Mentor do
  menu parent: 'Mentoring'

  controller do
    newrelic_ignore
  end

  show do
    attributes_table do
      row :user
      row :company
      row :availability do |mentor|
        availability_as_string(mentor.availability)
      end
      row :company_level
      row :verified? do |mentor|
        if mentor.verified?
          "Verified at #{mentor.verified_at}"
        else
          link_to 'Set mentor to verified', verify_admin_mentor_path, data: { confirm: 'Are you sure you want to verify this mentor?' }
        end
      end
    end
  end

  member_action :verify do
    mentor = Mentor.find params[:id]
    mentor.update(verified_at: Time.now)
    UserMailer.mentor_verified(mentor).deliver_now
    redirect_to admin_mentor_url, notice: "Mentor verified"
  end

  form do |f|
    f.inputs 'Mentor' do
    f.input :user
    f.input :company
    f.input :days_available, collection: Mentor.valid_days_available
    f.input :time_available, collection: Mentor.valid_time_available
    f.input :company_level, collection: Startup.valid_product_progress_values
    f.input :verified_at, as: :date_select
    end
    f.actions
  end



  permit_params :user_id, :company, :days_available, :time_available, :company_level, :verified_at
end
