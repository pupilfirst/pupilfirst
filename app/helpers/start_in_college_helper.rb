module StartInCollegeHelper
  def previous_page
    return previous_section unless section_number == 1
    return start_in_college_start_path if chapter_number == 1
    quiz_of_previous_chapter
  end

  def next_page
    return quiz_of_this_chapter if last_section?
    next_section
  end

  def chapter_number
    params[:id].to_i
  end

  def section_number
    params[:section_id].to_i
  end

  def quiz_of_previous_chapter
    start_in_college_quiz_path(chapter_number - 1)
  end

  def previous_section
    start_in_college_chapter_path(chapter_number, section_number - 1)
  end

  def last_section?
    section_number == CourseChapter.find_by(chapter_number: chapter_number).sections_count
  end

  def next_section
    start_in_college_chapter_path(chapter_number, section_number + 1)
  end

  def quiz_of_this_chapter
    start_in_college_quiz_path(chapter_number)
  end

  def quiz_result_title
    return "Great! You scored #{quiz_score}%!" if quiz_score > 80
    return "Not Bad! You scored #{quiz_score}%!" if quiz_score > 50
    "You scored #{quiz_score}%. You can do better!"
  end

  def after_quiz_path
    return start_in_college_course_end_path if last_quiz?
    start_of_next_chapter
  end

  def last_quiz?
    @chapter.chapter_number == CourseChapter.maximum(:chapter_number)
  end

  def start_of_next_chapter
    start_in_college_chapter_path(@chapter.chapter_number + 1, 1)
  end
end
