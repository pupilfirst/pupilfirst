ActiveAdmin.register_page 'Onboard Teams' do
  controller do
    include DisableIntercom
  end

  menu parent: 'Admissions'

  content do
    render 'form', form: Admin::OnboardTeamForm.new(Reform::OpenForm.new)
  end

  page_action :onboard, method: :post do
    form = Admin::OnboardTeamForm.new(Reform::OpenForm.new)
    if form.validate(params[:admin_onboard_team].merge(members: params[:members].values))
      team = form.save
      redirect_to admin_startup_path(team)
    else
      render '_form', locals: { form: form }
    end
  end
end
