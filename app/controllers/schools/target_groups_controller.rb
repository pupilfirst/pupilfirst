module Schools
  class TargetGroupsController < SchoolsController
    before_action :target_group, except: :create

    # POST /school/courses/:course_id/levels/:level_id/target_groups
    def create
      authorize(TargetGroup, policy_class: Schools::TargetGroupPolicy)
      form = ::Schools::TargetGroups::CreateForm.new(TargetGroup.new)
      if form.validate(create_params)
        form.save
        redirect_back(fallback_location: school_course_curriculum_path(params[:course_id]))
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # PATCH /school/target_groups/:id
    def update
      form = ::Schools::TargetGroups::UpdateForm.new(target_group)
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
      target_group.destroy!
      redirect_back(fallback_location: school_course_curriculum_path(course))
    end

    private

    def level
      target_group.level
    end

    def target_group
      @target_group = authorize(TargetGroup.find(params[:id]), policy_class: Schools::TargetGroupPolicy)
    end

    def create_params
      params.require(:target_group).permit(:name, :description, :sort_index, :milestone).merge(level_id: params[:level_id])
    end

    def update_params
      params.require(:target_group).permit(:name, :description, :sort_index, :milestone)
    end
  end
end
