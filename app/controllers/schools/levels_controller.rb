module Schools
  class LevelsController < SchoolsController
    before_action :level, except: :create

    # POST /school/courses/:course_id/levels
    def create
      course = Course.find(params[:course_id])
      new_level = authorize(Level.new(course: course), policy_class: Schools::LevelPolicy)

      form = ::Schools::Levels::CreateForm.new(new_level)
      if form.validate(params[:level])
        level = form.save
        render json: { id: level.id.to_s, number: level.number, error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    # PATCH /school/levels/:id
    def update
      form = ::Schools::Levels::UpdateForm.new(level)
      if form.validate(params[:level])
        level = form.save
        render json: { id: level.id.to_s, number: level.number, error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    private

    def level
      @level = authorize(Level.find(params[:id]), policy_class: Schools::LevelPolicy)
    end
  end
end
