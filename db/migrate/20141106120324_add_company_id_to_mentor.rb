class AddCompanyIdToMentor < ActiveRecord::Migration
  def change
    add_reference :mentors, :company, index: true
  end
end
