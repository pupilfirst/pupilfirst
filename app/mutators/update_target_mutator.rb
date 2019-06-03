class UpdateTargetMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :title
  attr_accessor :role
  attr_accessor :target_action_type
  attr_accessor :archived

  property :role, validates: { presence: true }
  property :title, validates: { presence: true, length: { maximum: 250 } }
  property :description
  property :target_action_type, validates: { presence: true }
  property :target_group_id, validates: { presence: true }
  property :sort_index
  property :youtube_video_id
  property :resource_ids
  property :prerequisite_target_ids
  property :evaluation_criterion_ids
  property :quiz
  property :link_to_complete
  property :archived

  validates :title, presence: { message: 'TitleBlank' }
  validates :role, presence: { messaage: 'RoleBlank' }
  validates :target_action_type, presence: { messaage: 'TargetActionTypeBlank' }

  def update_target
    target = Target.update!(title: title, role: role, target_action_type: target_action_type, archived: archived)
    target
  end
end
