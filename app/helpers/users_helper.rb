module UsersHelper
  def startup_html(startup)
    if startup.present?
      link_to startup.try(:name), startup_url(startup)
    else
      '<em>Not member of a Startup yet</em>'.html_safe
    end
  end

  def value_or_not_available(value)
    if value.blank?
      '<em>Not Available</em>'.html_safe
    else
      value
    end
  end

  def married_html(married_boolean)
    case married_boolean
      when true
        'Married'
      when false
        'Unmarried'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

  def current_occupation_html(occupation)
    case occupation
      when User::CURRENT_OCCUPATION_SELF_EMPLOYED
        'Self-employed'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

  def educational_qualification_html(qualification)
    case qualification
      when User::EDUCATIONAL_QUALIFICATION_BELOW_MATRICULATION
        'Below matriculation (< 10th)'
      when User::EDUCATIONAL_QUALIFICATION_MATRICULATION
        'Matriculation (10th)'
      when User::EDUCATIONAL_QUALIFICATION_HIGHER_SECONDARY
        'Higher Secondary (12th)'
      when User::EDUCATIONAL_QUALIFICATION_GRADUATE
        'Graduate'
      when User::EDUCATIONAL_QUALIFICATION_POSTGRADUATE
        'Postgraduate'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

  def religion_html(religion)
    case religion
      when User::RELIGION_HINDU
        'Hindu'
      when User::RELIGION_MUSLIM
        'Muslim'
      when User::RELIGION_CHRISTIAN
        'Christian'
      when User::RELIGION_SIKH
        'Sikh'
      when User::RELIGION_BUDDHIST
        'Buddhist'
      when User::RELIGION_JAIN
        'Jain'
      when User::RELIGION_OTHER
        'Other'
      else
        '<em>Unknown</em>'.html_safe
    end
  end

end
