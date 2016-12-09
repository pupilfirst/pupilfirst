class TargetGroupDecorator < Draper::Decorator
  delegate_all
  decorates_association :targets
end
