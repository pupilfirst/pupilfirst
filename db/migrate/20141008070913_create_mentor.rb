class CreateMentor < ActiveRecord::Migration
  def change
    create_table :mentors do |t|
      t.references :user
      t.string :time_availability
      t.string :company_level
      t.string :first_skill
      t.string :first_skill_expertise
      t.string :second_skill
      t.string :second_skill_expertise
      t.string :third_skill
      t.string :third_skill_expertise
      t.integer :cost_to_company
      t.integer :time_donate_percentage
      t.datetime :verified_at
    end
  end
end
