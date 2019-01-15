module Schools
  class LevelsController < SchoolsController
    before_action :level, except: :create

    # POST /school/courses/:course_id/levels
    def create
      authorize(Level, policy_class: Schools::LevelPolicy)
      form = ::Schools::Levels::CreateForm.new(Level.new)
      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: school_course_curriculum_path(params[:course_id]))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # PATCH /school/levels/:id
    def update
      form = ::Schools::Levels::UpdateForm.new(level)
      if form.validate(update_params)
        form.save
        redirect_back(fallback_location: school_course_curriculum_path(level.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # DELETE /school/levels/:id
    def destroy
      course = level.course
      level.destroy!
      redirect_back(fallback_location: school_course_curriculum_path(course))
    end

    private

    def level
      @level = authorize(Level.find(params[:id]), policy_class: Schools::LevelPolicy)
    end

    def create_params
      params.require(:level).permit(:name, :description, :number).merge(course_id: params[:course_id])
    end

    def update_params
      params.require(:level).permit(:name, :description, :number)
    end
  end
end
