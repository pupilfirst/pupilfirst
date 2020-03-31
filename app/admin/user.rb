ActiveAdmin.register User do
  menu parent: 'Dashboard'
  actions :index, :show, :new, :create

  permit_params :email

  filter :email
  filter :name
  filter :founders_id_not_null, label: 'Is a founder', as: :boolean
  filter :faculty_id_not_null, label: 'Is a faculty', as: :boolean

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes({ founders: { startup: :course } }, faculty: :school)
    end
  end

  index do
    selectable_column

    column :email

    column :founder do |user|
      render('founders', user: user) if user.founders.exists?
    end

    column :faculty do |user|
      link_to "#{user.name} (#{user.school.name})", admin_faculty_path(user.faculty) if user.faculty.present?
    end

    actions
  end

  show do
    attributes_table do
      row :email

      row :founders do |user|
        render('founders', user: user) if user.founders.exists?
      end

      row :faculty do |user|
        link_to "#{user.name} (#{user.school.name})", admin_faculty_path(user.faculty) if user.faculty.present?
      end

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
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'User Details' do
      f.input :email
    end

    f.actions
  end

  member_action :toggle_sign_out_at_next_request, method: :patch do
    user = User.find(params[:id])
    user.toggle :sign_out_at_next_request
    user.save!
    flash[:success] = "Sign out at next request is now #{user.reload.sign_out_at_next_request ? 'active' : 'inactive'}!"

    redirect_to action: :show
  end

  action_item :impersonate, only: :show do
    link_to('Impersonate', impersonate_admin_user_path(user), method: :post) if AdminUser.where(email: user.email).empty?
  end

  member_action :impersonate, method: :post do
    user = User.find(params[:id])

    # clear any previous impersonations
    stop_impersonating_user

    if AdminUser.where(email: user.email).exists?
      flash[:error] = 'You may not impersonate another admin user!'
    else
      impersonate_user(user)
      redirect_to params[:referer] || root_url
      return
    end

    redirect_to admin_user_path(user)
  end
end
