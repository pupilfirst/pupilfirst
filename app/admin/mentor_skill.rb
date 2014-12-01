ActiveAdmin.register MentorSkill do
  controller do
    newrelic_ignore
  end

  form do |f|
    f.inputs 'Skill' do
      f.input :mentor
      f.input :skill, collection: Category.mentor_skill_category
      f.input :expertise, collection: MentorSkill.valid_expertise_values
    end

    f.actions
  end

  permit_params :mentor_id, :skill_id, :expertise
end
