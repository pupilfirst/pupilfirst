module Targets
  class ArchivalService
    def initialize(target, params)
      @target = target
      @params = params
    end

    def execute
      if @params[:archived] == 'true'
        # Clean-up entries reference of the target in the TargetPrerequisite join table
        target_prerequisites = TargetPrerequisite.where('target_id = ? OR prerequisite_target_id = ?', @target.id, @target.id)
        target_prerequisites.destroy_all if target_prerequisites.present?
        @target.update!(archived: true)
      elsif @params[:archived] == 'false'
        @target.update!(archived: false)
      end
    end
  end
end
