class AddCompanyIdToMentor < ActiveRecord::Migration[4.2]
  def change
    add_reference :mentors, :company, index: true
  end
end
