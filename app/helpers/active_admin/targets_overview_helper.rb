module ActiveAdmin
  module TargetsOverviewHelper
    def templates_to_show
      TargetTemplate.where(id: Target.all.pluck(:target_template_id).uniq)
    end
  end
end
