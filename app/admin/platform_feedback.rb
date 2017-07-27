ActiveAdmin.register PlatformFeedback do
  include DisableIntercom

  menu parent: 'Dashboard', label: 'Platform Feedback'

  permit_params :founder_id, :feedback_type, :description, :attachment, :promoter_score, :notes

  filter :founder_name, as: :string
  filter :founder_email, as: :string
  filter :feedback_type
  filter :created_at
  filter :notes

  index do
    selectable_column

    column :feedback_type
    column :founder

    column :description do |feedback|
      truncate(feedback.description, length: 200)
    end

    column :karma_point do |feedback|
      if feedback.karma_point.present?
        link_to feedback.karma_point.points, admin_karma_point_path(feedback.karma_point)
      else
        link_to 'Add', admin_platform_feedback_path(feedback)
      end
    end

    column 'PS', :promoter_score

    actions
  end

  show do |feedback|
    attributes_table do
      row :feedback_type
      row :founder
      row :description

      row :attachment do
        if feedback.attachment.present?
          link_to feedback.attachment_filename, feedback.attachment.url, target: '_blank'
        end
      end

      row :promoter_score

      row :karma_point do
        if feedback.karma_point.present?
          link_to feedback.karma_point.points, admin_karma_point_path(feedback.karma_point)
        end
      end

      row :notes
      row :created_at
    end

    render partial: 'assign_karma_point_form', locals: { platform_feedback: feedback } if feedback.karma_point.blank?
  end

  member_action :assign_karma_point, method: :post do
    platform_feedback = PlatformFeedback.find params[:id]

    if params[:karma_point].present?
      KarmaPoints::CreateService.new(platform_feedback, params[:karma_point]).execute
    end

    platform_feedback.update(notes: params[:notes]) if params[:notes].present?

    redirect_to action: :show
  end

  member_action :redirect_to_attachment, method: :get do
    platform_feedback = PlatformFeedback.find params[:id]

    if platform_feedback.attachment.present?
      redirect_to platform_feedback.attachment.url
    else
      flash[:error] = 'This entry has no attachment.'
      redirect_to admin_platform_feedback_path(platform_feedback)
    end
  end
end
