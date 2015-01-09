ActiveAdmin.register MentorSkill do
  menu parent: 'Mentoring'

  controller do
    newrelic_ignore
  end

  form do |f|
    f.inputs 'Skill' do
      f.input :mentor
      f.input :skill, collection: proc { Category.mentor_skill_category }
      f.input :expertise, collection: proc { MentorSkill.valid_expertise_values }
    end

    f.actions
  end

  permit_params :mentor_id, :skill_id, :expertise
end
