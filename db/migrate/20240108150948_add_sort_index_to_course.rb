class AddSortIndexToCourse < ActiveRecord::Migration[7.0]
  class Course < ApplicationRecord
  end

  def change
    add_column :courses, :sort_index, :integer, default: 0

    Course
      .order(name: :asc)
      .each_with_index { |course, index| course.update!(sort_index: index) }
  end
end
