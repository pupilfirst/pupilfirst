ActiveAdmin.register EnglishQuizQuestion do
  menu parent: 'English Quiz', label: 'Questions'
  permit_params :question, :explanation

  filter :explanation
  filter :created_at

  show do |question|
    attributes_table do
      row :question do
        link_to question.question.url do
          image_tag question.question.url, width: '400px'
        end
      end

      row :explanation
    end
  end

  index do
    selectable_column

    column :question do |question|
      link_to question.question.url do
        image_tag question.question.url, width: '200px'
      end
    end

    column :explanation
    column :created_at

    actions
  end
end
