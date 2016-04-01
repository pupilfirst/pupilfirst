class TargetTemplate < ActiveRecord::Base
  belongs_to :assigner, class_name: 'Faculty'

  mount_uploader :rubric, RubricUploader

  # ensure required fields for a target (which cannot be auto-alloted) are specified
  validates_presence_of :role, :title, :description, :assigner_id

  def due_date(batch: Batch.current_or_last)
    (batch.start_date + days_from_start).to_date
  end

  # Create a target using this template.
  def create_target!(assignee)
    Target.create!(
      assignee: assignee,
      status: Target::STATUS_PENDING,
      role: role,
      title: title,
      description: description,
      assigner: assigner,
      resource_url: resource_url,
      completion_instructions: completion_instructions,
      due_date: due_date.end_of_day,
      slideshow_embed: slideshow_embed
    )
  end

  def founder_role?
    role == Target::ROLE_FOUNDER
  end
end
