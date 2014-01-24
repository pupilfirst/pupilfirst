class RemoveCategoriesFromStartups < ActiveRecord::Migration
  def change
    remove_reference :startups, :primary_category
    remove_reference :startups, :secondary_category
    remove_reference :startups, :other_category
  end
end
