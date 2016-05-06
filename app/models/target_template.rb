class TargetTemplate < ActiveRecord::Base
  belongs_to :assigner, class_name: 'Faculty'
  has_many :targets

  mount_uploader :rubric, RubricUploader

  scope :founder_role, -> { where(role: Target::ROLE_FOUNDER) }
  scope :team_role, -> { where.not(id: founder_role) }

  # ensure required fields for a target (which cannot be auto-alloted) are specified
  validates_presence_of :role, :title, :description, :assigner_id

  def due_date(batch: Batch.current_or_last)
    days_from_start.present? ? (batch.start_date + days_from_start).to_date.end_of_day : nil
  end

  # Create a target using this template.
  def create_target!(assignee, batch: Batch.current_or_last)
    Target.create!(
      assignee: assignee,
      status: Target::STATUS_PENDING,
      role: role,
      title: title,
      description: description,
      assigner: assigner,
      resource_url: resource_url,
      completion_instructions: completion_instructions,
      due_date: due_date(batch: batch),
      slideshow_embed: slideshow_embed,
      review_test_embed: review_test_embed,
      target_template: self,
      rubric: rubric
    )
  end

  def founder_role?
    role == Target::ROLE_FOUNDER
  end
end
