module ApplicationHelper

  def fmt_time(t)
    raise ArgumentError.new("Should be a instance of Time/Date/DateTime. #{t.class} given.") unless t.is_a?(Time) or t.is_a?(Date) or t.is_a?(DateTime)
    t.strftime("%F %R%z")
  end
end
