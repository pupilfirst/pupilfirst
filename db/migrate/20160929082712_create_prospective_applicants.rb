class CreateProspectiveApplicants < ActiveRecord::Migration
  def change
    create_table :prospective_applicants do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :college, index: true
      t.string :college_text

      t.timestamps null: false
    end
  end
end
