class ProgramWeekDecorator < Draper::Decorator
  delegate_all
  decorates_association :target_groups
end
