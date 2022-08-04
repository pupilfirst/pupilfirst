class FixSchoolLinksSortIndices < ActiveRecord::Migration[6.1]
  def up
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
    raise ActiveRecord::IrreversibleMigration
  end
end
