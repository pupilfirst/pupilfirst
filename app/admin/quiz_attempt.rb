ActiveAdmin.register QuizAttempt do
  menu parent: 'StartInCollege'

  index do
    selectable_column

    column :course_chapter
    column :mooc_student
    column :score
    column :created_at

    actions
  end
end
