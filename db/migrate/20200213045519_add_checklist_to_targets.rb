class AddChecklistToTargets < ActiveRecord::Migration[6.0]
  class TargetEvaluationCriterion < ApplicationRecord
    belongs_to :target
  end

  def up
    add_column :targets, :checklist, :jsonb, default: []

    Target.reset_column_information

    Target.where(id: TargetEvaluationCriterion.all.pluck(:target_id).uniq).each do |target|
      target.update!(checklist: default_checklist)
    end
  end

  def down
    remove_column :targets, :checklist
  end

  def default_checklist
    description = {
      title: "Describe your submission",
      kind: "longText",
      optional: false,
    }

    link =
      {
        title: "Attach a link",
        optional: true,
        kind: "link",

      }

    file =
      {
        title: "Attach files",
        optional: true,
        kind: "files",
      }

    [description, link, file]
  end
end
