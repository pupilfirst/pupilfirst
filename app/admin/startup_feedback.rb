ActiveAdmin.register StartupFeedback do

menu parent: 'Startups'
permit_params :feedback, :reference_url, :startup_id, :send_email

index do
  selectable_column
  column :startup
  column :feedback
  column :reference_url
  column :send_at do |startup_feedback|
    if startup_feedback.send_at.present?
      startup_feedback.send_at
    else
      link_to('Email Now!', email_feedback_admin_startup_feedback_path(startup_feedback), method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founders?' })
    end
  end
  actions
end

show do
  attributes_table do
    row :startup
    row :feedback
    row :reference_url
    row :send_at do |startup_feedback|
      if startup_feedback.send_at.present?
        startup_feedback.send_at
      else
        link_to('Email Now!', email_feedback_admin_startup_feedback_path(startup_feedback), method: :put, data: { confirm: 'Are you sure you want to email this feedback to the founders?' })
      end
    end
  end
end

form partial: 'admin/startup_feedbacks/form'

member_action :email_feedback, method: :put do
  startup_feedback = StartupFeedback.find params[:id]
  startup_feedback.update(send_at: Time.now)
  StartupMailer.feedback_as_email(startup_feedback,current_admin_user).deliver_later
  flash[:alert] = 'Your feedback has been sent to the startup founders!'
  redirect_to action: :index
end


end
