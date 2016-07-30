module StartInCollegeHelper
  def previous_page
    return previous_chapter unless chapter_number == 1
    return start_in_college_start_path if module_number == 1
    quiz_of_previous_module
  end

  def next_page
    return quiz_of_this_module if last_chapter?
    next_chapter
  end

  def module_number
    params[:id].to_i
  end

  def chapter_number
    params[:chapter_id].to_i
  end

  def quiz_of_previous_module
    start_in_college_quiz_path(module_number - 1)
  end

  def previous_chapter
    start_in_college_module_path(module_number, chapter_number - 1)
  end

  def last_chapter?
    chapter_number == CourseModule.find_by(module_number: module_number).chapters_count
  end

  def next_chapter
    start_in_college_module_path(module_number, chapter_number + 1)
  end

  def quiz_of_this_module
    start_in_college_quiz_path(module_number)
  end

  def quiz_result_title
    return "Great! You scored #{quiz_score}%!" if quiz_score > 80
    return "Not Bad! You scored #{quiz_score}%!" if quiz_score > 50
    "You scored #{quiz_score}%. You can do better!"
  end

  def after_quiz_path
    return start_in_college_course_end_path if last_quiz?
    start_of_next_module
  end

  def last_quiz?
    @module.module_number == CourseModule.maximum(:module_number)
  end

  def start_of_next_module
    start_in_college_module_path(@module.module_number + 1, 1)
  end
end
