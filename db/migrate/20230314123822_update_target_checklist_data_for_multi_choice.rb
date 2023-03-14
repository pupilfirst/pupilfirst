class UpdateTargetChecklistDataForMultiChoice < ActiveRecord::Migration[6.1]
  def up
    # Get all targets with multi-choice checklist item
    applicable_targets =
      Target.where('checklist @> ?', [{ kind: 'multiChoice' }].to_json)

    applicable_targets.each do |target|
      checklist = target.checklist

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

    #  Get all evaluated submissions with multiChoice checklist items
    applicable_submissions =
      TimelineEvent.where('checklist @> ?', [{ kind: 'multiChoice' }].to_json)

    applicable_submissions.each do |timeline_event|
      checklist = timeline_event.checklist

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
