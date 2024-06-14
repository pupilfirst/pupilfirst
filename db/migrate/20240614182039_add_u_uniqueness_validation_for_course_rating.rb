class AddUUniquenessValidationForCourseRating < ActiveRecord::Migration[7.0]
  def change
    add_index :course_ratings, %i[user_id course_id], unique: true
  end
end
