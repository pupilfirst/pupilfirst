class CreateStudentEntrepreneurPolicies < ActiveRecord::Migration
  def change
    create_table :student_entrepreneur_policies do |t|
      t.string :certificate_pic
      t.string :university_registeration_number
      t.text :address
      t.references :user, index: true

      t.timestamps
    end
  end
end
