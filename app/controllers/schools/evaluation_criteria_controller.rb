module Schools
  class EvaluationCriteriaController < SchoolsController
    before_action :criterion, except: :create

    # POST /school/courses/:course_id/evaluation_criteria
    def create
      authorize(EvaluationCriterion, policy_class: Schools::EvaluationCriterionPolicy)
      form = ::Schools::EvaluationCriteria::CreateForm.new(EvaluationCriterion.new)
      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: curriculum_school_course_path(params[:course_id]))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # PATCH /school/evaluation_criteria/:id
    def update
      form = ::Schools::EvaluationCriteria::UpdateForm.new(criterion)
      if form.validate(update_params)
        form.save
        redirect_back(fallback_location: curriculum_school_course_path(criterion.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # DELETE /school/evaluation_criteria/:id
    def destroy
      course = criterion.course
      criterion.destroy!
      redirect_back(fallback_location: curriculum_school_course_path(course))
    end

    private

    def criterion
      @criterion = authorize(EvaluationCriterion.find(params[:id]), policy_class: Schools::EvaluationCriterionPolicy)
    end

    def create_params
      params.require(:evaluation_criterion).permit(:name, :description).merge(course_id: params[:course_id])
    end

    def update_params
      params.require(:evaluation_criterion).permit(:name, :description)
    end
  end
end
