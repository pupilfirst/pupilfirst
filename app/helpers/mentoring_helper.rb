module MentoringHelper
  def availability_days_collection
    {
      'Every day' => Mentor::AVAILABILITY_DAYS_EVERYDAY,
      'Weekdays' => Mentor::AVAILABILITY_DAYS_WEEKDAYS,
      'Weekends' => Mentor::AVAILABILITY_DAYS_WEEKENDS
    }
  end

  def availability_time_collection
    {
      'All day' => Mentor::AVAILABILITY_TIME_ALL_DAY,
      'Morning' => Mentor::AVAILABILITY_TIME_MORNING,
      'Midday' => Mentor::AVAILABILITY_TIME_MIDDAY,
      'Afternoon' => Mentor::AVAILABILITY_TIME_AFTERNOON,
      'Evening' => Mentor::AVAILABILITY_TIME_EVENING
    }
  end

  def mentor_skills_expertise_options
    options_for_select([
        ['Intermediate', MentorSkill::EXPERTISE_INTERMEDIATE],
        ['Advanced', MentorSkill::EXPERTISE_ADVANCED],
        ['Expert', MentorSkill::EXPERTISE_EXPERT]
      ])
  end

  def meeting_status_html(status)
    status = "Rescheduled (to be confirmed)" if status == MentorMeeting::STATUS_RESCHEDULED
    status.gsub('_', ' ').capitalize
  end

  def badges_for_days(days)
    days.map do |day|
      "<span class='badge'>#{day[0..2].upcase}</span>"
    end.join(' ').html_safe
  end
end
