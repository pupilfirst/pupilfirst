class DropCompany < ActiveRecord::Migration
  def change
  	drop_table :companies
  end
end
