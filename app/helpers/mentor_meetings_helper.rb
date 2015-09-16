module MentorMeetingsHelper
  include MentoringHelper

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def availability_as_string(availability)
    day = case availability['days']
      when Date::DAYNAMES then
        'Everyday'
      when Date::DAYNAMES[1..5] then
        'Weekdays'
      when Date::DAYNAMES - Date::DAYNAMES[1..5] then
        'Weekends'
      else availability['days']
    end

    time = case availability['time']['after']
      when 8
        if availability['time']['after'] == 11
          'Morning'
        else
          'All day'
        end
      when 11
        'Midday'
      when 14
        'Afternoon'
      when 17
        'Evening'
      else
        'All day'
    end

    "#{day}, #{time}"
  end

  def mentor_rating_list
    {
      'Not my Expertise' => MentorMeeting::RATING_0,
      'Skeptic' => MentorMeeting::RATING_1,
      'Unsure' => MentorMeeting::RATING_2,
      'Too early to say' => MentorMeeting::RATING_3,
      'Hopeful' => MentorMeeting::RATING_4,
      'Very Promising' => MentorMeeting::RATING_5
    }
  end

  def user_rating_list
    {
      'Mentor Expectations not met' => MentorMeeting::RATING_0,
      'Little use' => MentorMeeting::RATING_1,
      'Some use' => MentorMeeting::RATING_2,
      'Useful' => MentorMeeting::RATING_3,
      'Really Useful' => MentorMeeting::RATING_4,
      'Eye opening' => MentorMeeting::RATING_5
    }
  end

  def durations_list
    {
      '15 Mins' => MentorMeeting::DURATION_QUARTER_HOUR,
      '30 Mins' => MentorMeeting::DURATION_HALF_HOUR,
      'One hour' => MentorMeeting::DURATION_HOUR
    }
  end

  def time_list
    [
      Mentor::AVAILABILITY_TIME_MORNING, Mentor::AVAILABILITY_TIME_MIDDAY, Mentor::AVAILABILITY_TIME_AFTERNOON,
      Mentor::AVAILABILITY_TIME_EVENING
    ].each_with_object({}) do |element, result|
      result[element.capitalize] = element
    end
  end

  def current_mentor
    current_user.try(:mentor)
  end

  def guest_title(mentor_meeting)
    mentor_meeting.mentor?(current_user) ? 'startup founder' : 'mentor'
  end
end
