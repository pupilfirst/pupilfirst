class AddExitedOnToFoundersTable < ActiveRecord::Migration[6.0]
  class Founder < ActiveRecord::Base
  end

  def change
    add_column :founders, :exited_at, :datetime

    Founder.reset_column_information
    Founder.all.each do |f|
      next unless f.exited?

      f.update!(exited_at: f.updated_at)
    end
  end
end
