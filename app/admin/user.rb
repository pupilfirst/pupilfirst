ActiveAdmin.register User do
  include DisableIntercom

  menu parent: 'Dashboard'
  actions :index, :show

  filter :email

  index do
    selectable_column

    column :email
    column :mooc_student
    column :founder

    actions
  end

  show do
    attributes_table do
      row :email
      row :mooc_student
      row :founder

      row :sign_out_at_next_request do |user|
        if user.sign_out_at_next_request?
          span "User will be signed out (once per week) when he visits. #{link_to 'Turn this off.', toggle_sign_out_at_next_request_admin_user_path, method: :patch}".html_safe
        else
          span "Inactive. #{link_to 'Turn this on', toggle_sign_out_at_next_request_admin_user_path, method: :patch, data: { confirm: 'Are you sure?' }} to sign out the user (once per week) when he visits.".html_safe
        end
      end
    end

    panel 'Technical details' do
      attributes_table_for user do
        row :id
        row :login_token
        row :email_bounced_at
        row :email_bounce_type
      end
    end
  end

  member_action :toggle_sign_out_at_next_request, method: :patch do
    user = User.find(params[:id])
    user.toggle :sign_out_at_next_request
    user.save!
    flash[:success] = "Sign out at next request is now #{user.reload.sign_out_at_next_request ? 'active' : 'inactive'}!"

    redirect_to action: :show
  end
end
