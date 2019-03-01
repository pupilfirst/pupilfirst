module Schools
  class CurriculaController < SchoolsController
    layout 'course'

    def show
      course = courses.where(id: params[:course_id]).includes([:evaluation_criteria, :levels, :target_groups, targets: [:evaluation_criteria, :prerequisite_targets, :resources, quiz: { quiz_questions: %I[answer_options correct_answer] }]]).first
      @course = authorize(course, policy_class: Schools::CurriculaPolicy)
    end
  end
end
