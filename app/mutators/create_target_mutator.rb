class CreateTargetMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :title
  attr_accessor :target_group_id

  validates :title, presence: { message: 'TitleBlank' }
  validates :target_group_id, presence: { message: 'TargetGroupIdBlank' }

  def create_target
    target = Target.create!(title: title, target_group_id: target_group_id, role: 'founder', target_action_type: 'Todo', visibility: 'draft')
    target
  end
end
