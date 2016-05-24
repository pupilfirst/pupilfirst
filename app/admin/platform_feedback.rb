ActiveAdmin.register PlatformFeedback do
  menu parent: 'Dashboard', label: 'Platform Feedback'

  permit_params :founder_id, :feedback_type, :description, :attachment, :promoter_score, :notes

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
          link_to feedback.attachment.url, target: '_blank' do
            image_tag feedback.attachment.url, width: '200px'
          end
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

    render partial: 'assign_karma_point_form', locals: { platform_feedback: feedback } unless feedback.karma_point.present?
  end

  member_action :assign_karma_point, method: :post do
    platform_feedback = PlatformFeedback.find params[:id]

    if params[:karma_point].present?
      KarmaPoint.create!(
        source: platform_feedback,
        founder: platform_feedback.founder,
        activity_type: "Submitted Platform Feedback on #{platform_feedback.created_at.strftime('%b %d, %Y')}",
        points: params[:karma_point]
      )
    end

    if params[:notes].present?
      platform_feedback.update(notes: params[:notes])
    end

    redirect_to action: :show
  end
end
