module MentoringHelper
  def company_level_label(product_progress)
    case product_progress
      when Startup::PRODUCT_PROGRESS_IDEA
        'Idea stage'
      when Startup::PRODUCT_PROGRESS_MOCKUP
        'Mockup stage'
      when Startup::PRODUCT_PROGRESS_PROTOTYPE
        'Prototyping'
      when Startup::PRODUCT_PROGRESS_PRIVATE_BETA
        'In Private Beta'
      when Startup::PRODUCT_PROGRESS_PUBLIC_BETA
        'In Public Beta'
      when Startup::PRODUCT_PROGRESS_LAUNCHED
        'Launched'
      else
        '<em>Not Known</em>'.html_safe
    end
  end

  def cost_to_company_collection
    {
      'Less than 3 lakh' => Mentor::CTC_BELOW_3L,
      'Between 3 lakh and 6 lakh' => Mentor::CTC_BETWEEN_3L_AND_6L,
      'Between 6 lakh and 12 lakh' => Mentor::CTC_BETWEEN_6L_AND_12L,
      'Between 12 lakh and 36 lakh' => Mentor::CTC_BETWEEN_12L_AND_36L,
      'Between 36 lakh and 1 crore' => Mentor::CTC_BETWEEN_36L_AND_1CR,
      'More than 1 crore' => Mentor::CTC_ABOVE_1_CR
    }
  end

  def time_donate_percentage_collection
    {
      '0%' => Mentor::DONATE_0,
      '25%' => Mentor::DONATE_25,
      '50%' => Mentor::DONATE_50,
      '75%' => Mentor::DONATE_75,
      '100%' => Mentor::DONATE_100
    }
  end

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
end
