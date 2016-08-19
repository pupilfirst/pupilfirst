# rubocop:disable Metrics/ModuleLength
module SixWaysHelper
  def previous_page_path
    return '#' unless @chapter.present?
    return previous_chapter_path unless chapter_number == 1
    return '#' if module_number == 1
    return quiz_of_previous_module if previous_module.quiz?
    last_chapter_of_previous_module
  end

  def next_page_path
    return '#' unless @chapter.present?
    return next_chapter_path unless last_chapter?
    return quiz_of_this_module if @module.quiz?
    return start_of_next_module unless last_module?
    '#'
  end

  def previous_button_title
    return 'Previous' unless @chapter.present?
    return previous_chapter.name unless chapter_number == 1
    return 'Previous Chapter' if module_number == 1
    return 'Retake Previous Quiz' if previous_module.quiz?
    previous_module.module_chapters.find_by(chapter_number: previous_module.chapters_count).name
  end

  def next_button_title
    return 'Next' unless @chapter.present?
    return next_chapter.name unless last_chapter?
    return 'Take Quiz' if @module.quiz?
    next_module.module_chapters.find_by(chapter_number: 1).name unless last_module?
    'Next'
  end

  def module_number
    @module.module_number
  end

  def module_name
    @module.name
  end

  def previous_module
    CourseModule.find_by(module_number: module_number - 1)
  end

  def next_module
    CourseModule.find_by(module_number: module_number + 1)
  end

  def previous_chapter
    @module.module_chapters.find_by(chapter_number: chapter_number - 1)
  end

  def next_chapter
    @module.module_chapters.find_by(chapter_number: chapter_number + 1)
  end

  def first_module
    CourseModule.find_by(module_number: 1)
  end

  def first_chapter
    first_module.module_chapters.find_by(chapter_number: 1)
  end

  def chapter_number
    @chapter.chapter_number
  end

  def quiz_of_previous_module
    six_ways_quiz_path(previous_module.slug)
  end

  def previous_chapter_path
    six_ways_module_path(@module.slug, previous_chapter.slug)
  end

  def last_chapter?
    chapter_number == @module.chapters_count
  end

  def last_module?
    @module.module_number == CourseModule.maximum(:module_number)
  end

  def next_chapter_path
    six_ways_module_path(@module.slug, next_chapter.slug)
  end

  def quiz_of_this_module
    six_ways_quiz_path(@module.slug)
  end

  def quiz_result_title
    return "Great! You scored #{quiz_score}%!" if quiz_score > 80
    return "Not Bad! You scored #{quiz_score}%!" if quiz_score > 50
    "You scored #{quiz_score}%. You can do better!"
  end

  def after_quiz_path
    return six_ways_course_end_path if last_quiz_attempted?
    start_of_next_module
  end

  def last_quiz_attempted?
    current_mooc_student.quiz_attempts.maximum(:course_module_id) == CourseModule.last_module.id
  end

  def start_of_next_module
    six_ways_module_path(next_module.slug, next_module.module_chapters.find_by(chapter_number: 1).slug)
  end

  def first_chapter_path
    six_ways_module_path(first_module.slug, first_chapter.slug)
  end

  def module_has_quiz_header?
    lookup_context.exists?('quiz_header', ["six_ways/module_#{module_number}"], true)
  end

  def last_chapter_of_previous_module
    six_ways_module_path(previous_module.slug, previous_module.module_chapters.find_by(chapter_number: previous_module.chapters_count).slug)
  end

  def active_module_class?(course_module)
    course_module == @module ? 'active' : ''
  end

  def active_chapter_class?(chapter)
    chapter == @chapter ? 'active_chapter' : ''
  end

  def complete_chapter_class?(chapter)
    current_mooc_student.completed_chapter?(chapter) ? 'complete_chapter' : ''
  end

  def active_quiz_class?(course_module)
    quiz_page? && course_module == @module ? 'active_quiz' : ''
  end

  def complete_quiz_class?(course_module)
    current_mooc_student.completed_quiz?(course_module) ? 'complete_quiz' : ''
  end

  def fa_icon_of_chapter(chapter)
    if chapter == @chapter
      'fa-circle-o'
    elsif current_mooc_student.completed_chapter?(chapter)
      'fa-check-circle'
    else
      'fa-circle'
    end
  end

  def fa_icon_of_quiz(course_module)
    if quiz_page? && course_module == @module
      'fa-circle-o'
    elsif current_mooc_student.completed_quiz?(course_module)
      'fa-check-circle'
    else
      'fa-circle'
    end
  end

  def disabled_previous?(chapter)
    return 'disabled' if quiz_page?
    chapter == first_chapter ? 'disabled' : ''
  end

  def disabled_next?(_chapter)
    return 'disabled' if quiz_page?
    !@module.published? ? 'disabled' : ''
  end

  def quiz_page?
    @chapter.blank?
  end
end
# rubocop:enable Metrics/ModuleLength
