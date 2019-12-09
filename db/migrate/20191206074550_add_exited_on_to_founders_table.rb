class AddExitedOnToFoundersTable < ActiveRecord::Migration[6.0]
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

  def change
    add_column :startups, :exited_at, :datetime

    Startup.reset_column_information
    Founder.all.each do |student|
      next unless student.exited?

      if student.startup.founders.count > 1
        startup = Startup.create!(
          name: student.name,
          level_id: student.startup.level_id,
          exited_at: student.updated_at
        )
        student.update!(startup: startup)
      else
        student.startup.update!(exited_at: student.updated_at)
      end
    end
  end
end
