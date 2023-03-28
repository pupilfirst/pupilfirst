module DateHelper
  def date_to_zoned_time(date)
    Time.find_zone(ENV['SPEC_USER_TIME_ZONE']).parse(date)
  end
end
