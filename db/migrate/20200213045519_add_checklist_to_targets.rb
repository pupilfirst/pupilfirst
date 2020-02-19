class AddChecklistToTargets < ActiveRecord::Migration[6.0]
  class Target < ActiveRecord::Base
  end

  def up
    add_column :targets, :checklist, :jsonb, default: []

    Target.all.each do |target|
      target.update!(checklist: default_checklist)
    end
  end

  def down
    remove_column :targets, :checklist
  end

  def default_checklist
    description = {
      title: "Work on your submission",
      kind: "longText",
      optional: false,
    }

    link =
      {
        title: "Attach link",
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
