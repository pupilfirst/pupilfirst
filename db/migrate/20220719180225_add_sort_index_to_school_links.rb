class AddSortIndexToSchoolLinks < ActiveRecord::Migration[6.1]
  def up
    add_column :school_links, :sort_index, :integer, default: 0, null: false

    kinds = SchoolLink.distinct.pluck(:kind)

    kinds.each do |kind|
      SchoolLink.where(kind:kind).each_with_index do |cb, index|
        cb.update!(sort_index: index)
      end
    end

  end
  def down
    remove_column :school_links, :sort_index
  end
end
