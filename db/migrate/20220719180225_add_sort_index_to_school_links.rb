class AddSortIndexToSchoolLinks < ActiveRecord::Migration[6.1]
  def up
    add_column :school_links, :sort_index, :integer, default: 0, null: false

    kinds = SchoolLink::VALID_KINDS

    SchoolLink.reset_column_information

    School
      .joins(:school_links)
      .distinct
      .each do |school|
        kinds.each do |kind|
          school
            .school_links
            .where(kind: kind)
            .each_with_index { |link, index| link.update!(sort_index: index) }
        end
      end
  end

  def down
    remove_column :school_links, :sort_index
  end
end
