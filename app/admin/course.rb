ActiveAdmin.register Course do
  controller do
    include DisableIntercom
  end

  menu parent: 'Targets'

  filter :name

  permit_params :name, :sponsored, :max_grade, :pass_grade, :grade_labels, :ends_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :sponsored
      f.input :max_grade
      f.input :pass_grade
      f.input :grade_labels, as: :text, input_html: { value: f.object.grade_labels.to_json }
      f.input :ends_at, as: :datepicker
    end
    f.actions
  end
end
