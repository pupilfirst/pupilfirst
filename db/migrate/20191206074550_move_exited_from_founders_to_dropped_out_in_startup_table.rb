class MoveExitedFromFoundersToDroppedOutInStartupTable < ActiveRecord::Migration[6.0]
  class User < ActiveRecord::Base
    has_many :founders
  end

  class Founder < ActiveRecord::Base
    belongs_to :startup
    belongs_to :user

    delegate :name, to: :user
  end

  class Startup < ActiveRecord::Base
    has_many :founders
  end

  def up
    add_column :startups, :dropped_out_at, :datetime

    Startup.reset_column_information
    Founder.all.each do |student|
      next unless student.exited?

      if student.startup.founders.count > 1
        startup = Startup.create!(
          name: student.name,
          level_id: student.startup.level_id,
          dropped_out_at: student.updated_at
        )
        student.update!(startup: startup)
      else
        student.startup.update!(dropped_out_at: student.updated_at)
      end
    end

    remove_column :founders, :exited, :boolean
  end

  def down
    add_column :founders, :exited, :boolean

    Founder.reset_column_information

    Startup.all.each do |startup|
      next unless startup.dropped_out_at.present?

      startup.founders.update_all(exited: true)
    end

    remove_column :startups, :dropped_out_at, :datetime
  end
end
