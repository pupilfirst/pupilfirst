class AddDomainFieldsToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :subdomain, :string
    add_column :schools, :domain, :string
  end
end
