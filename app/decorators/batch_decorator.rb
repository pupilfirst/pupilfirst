class BatchDecorator < Draper::Decorator
  delegate_all

  def week_percentage
    ((present_week_number.to_f / 24) * 100).to_i
  end
end
