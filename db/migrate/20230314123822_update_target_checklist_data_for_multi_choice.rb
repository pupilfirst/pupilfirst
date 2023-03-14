class UpdateTargetChecklistDataForMultiChoice < ActiveRecord::Migration[6.1]
  def up
    # Get all reviewed targets
    reviewed_targets = Target.where.not("checklist = '[]'")

    reviewed_targets.each do |target|
      checklist = target.checklist

      next if checklist.find { |item| item['kind'] == 'multiChoice' }.nil?

      # Update checklist column of target
      updated_checklist =
        checklist.map do |item|
          if item['kind'] == 'multiChoice'
            item['metadata'] = {
              'allowMultiple' => false,
              'choices' => item['metadata']['choices']
            }
            item
          else
            item
          end
        end

      target.update!(checklist: updated_checklist)
    end

    #  Get all evaluated submissions
    evaluated_submissions = TimelineEvent.where.not("checklist = '[]'")

    evaluated_submissions.each do |timeline_event|
      checklist = timeline_event.checklist

      next if checklist.find { |item| item['kind'] == 'multiChoice' }.nil?

      updated_checklist =
        checklist.map do |item|
          if item['kind'] == 'multiChoice'
            item['result'] = [item['result']]
            item
          else
            item
          end
        end

      timeline_event.update!(checklist: updated_checklist)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
