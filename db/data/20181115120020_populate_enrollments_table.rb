class PopulateEnrollmentsTable < ActiveRecord::Migration[5.2]
  def up
    enrollment_data = Founder.pluck(:id, :user_id).map do |founder_id, user_id|
      { founder_id: founder_id, user_id: user_id }
    end

    Enrollment.create!(enrollment_data)
  end

  def down
    Enrollment.delete_all
  end
end
