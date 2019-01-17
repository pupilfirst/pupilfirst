module Schools
  class TargetsController < SchoolsController
    before_action :target, except: :create

    # POST /school/courses/:course_id/levels/:level_id/target_groups
    def create
      authorize(Target, policy_class: Schools::TargetPolicy)
      form = ::Schools::Targets::CreateForm.new(Target.new)
      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: school_course_curriculum_path(TargetGroup.find(params[:target_group_id]).level.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # PATCH /school/target_groups/:id
    def update
      form = ::Schools::Targets::UpdateForm.new(target)
      if form.validate(update_params)
        form.save
        redirect_back(fallback_location: school_course_curriculum_path(level.course))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # DELETE /school/target_groups/:id
    def destroy
      course = level.course
      target.destroy!
      redirect_back(fallback_location: school_course_curriculum_path(course))
    end

    private

    def level
      target_group.level
    end

    def target_group
      target.target_group
    end

    def target
      @target = authorize(Target.find(params[:id]), policy_class: Schools::TargetPolicy)
    end

    def create_params
      params.require(:target).permit(:role, :title, :description, :target_action_type, :sort_index).merge(target_group_id: params[:target_group_id])
    end

    def update_params
      params.require(:target).permit(:role, :title, :description, :target_action_type, :sort_index)
    end
  end
end
