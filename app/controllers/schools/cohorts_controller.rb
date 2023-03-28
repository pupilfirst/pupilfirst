module Schools
  class CohortsController < SchoolsController
    include CamelizeKeys
    include StringifyIds

    # POST /school/cohorts/:id/bulk_import_students
    def bulk_import_students
      @cohort =
        authorize(scope.find(params[:id]), policy_class: Schools::CohortPolicy)

      form = ::Cohorts::BulkImportStudentsForm.new(@cohort)
      form.current_user = current_user

      props =
        if form.validate(params)
          form.save
          { success: true }
        else
          { error: form.errors.full_messages.join(', ') }
        end

      render json: camelize_keys(stringify_ids(props))
    end

    private

    def scope
      @scope ||=
        policy_scope(Cohort, policy_scope_class: Schools::CohortPolicy::Scope)
    end
  end
end
