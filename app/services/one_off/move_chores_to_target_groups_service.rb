module OneOff
  class MoveChoresToTargetGroupsService
    include Loggable

    def execute
      chores = Target.where(chore: true).where.not(archived: true)

      log "Unarchived chores: #{chores.count}"

      chores.each do |chore|
        next if chore.level.blank?
        next unless chore.level.number.positive?

        log "Moving Chore Target##{chore.id} to TargetGroup##{target_groups[chore.level.number].id}"

        chore.target_group = target_groups[chore.level.number]
        chore.level = nil
        chore.save!
      end

      nil
    end

    private

    def target_groups
      @target_groups ||= begin
        chore_group = TargetGroup.where(name: 'Chores')

        {
          1 => chore_group.find_by(level: Level.find_by(number: 1)),
          2 => chore_group.find_by(level: Level.find_by(number: 2)),
          3 => chore_group.find_by(level: Level.find_by(number: 3)),
          4 => chore_group.find_by(level: Level.find_by(number: 4)),
          5 => chore_group.find_by(level: Level.find_by(number: 5))
        }
      end
    end
  end
end
