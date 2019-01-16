ActiveAdmin.register_page 'CSV Student Importer' do
  controller do
    include DisableIntercom
  end

  menu parent: 'Admissions'

  content do
    render 'form', form: Admin::CsvStudentImporterForm.new(Reform::OpenForm.new)
  end

  page_action :onboard, method: :post do
    form = Admin::CsvStudentImporterForm.new(Reform::OpenForm.new)
    if form.validate(params[:admin_csv_student_importer])
      form.save
      redirect_to admin_startups_url
    else
      render '_form', locals: { form: form }
    end
  end
end
