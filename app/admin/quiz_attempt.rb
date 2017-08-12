ActiveAdmin.register QuizAttempt do
  include DisableIntercom

  menu parent: 'SixWays'

  filter :course_module
  filter :mooc_student_name, as: :string
  filter :taken_at
  filter :score

  index do
    selectable_column

    column :course_module
    column :mooc_student
    column :score
    column :created_at

    actions
  end

  csv do
    column :id

    column :name do |quiz_attempt|
      quiz_attempt.mooc_student&.name
    end

    column :score
    column :total_questions
    column :attempted_questions
    column :created_at
  end
end
