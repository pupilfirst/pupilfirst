class DropCompany < ActiveRecord::Migration[4.2]
  def change
    execute 'drop table if exists companies'
  end
end
