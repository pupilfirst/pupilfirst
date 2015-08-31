module StartupsHelper
  def registration_type_html(registration_type)
    case registration_type
      when Startup::REGISTRATION_TYPE_PARTNERSHIP
        'Partnership'
      when Startup::REGISTRATION_TYPE_PRIVATE_LIMITED
        'Private Limited'
      when Startup::REGISTRATION_TYPE_LLP
        'Limited Liability Partnership'
      else
        '<em>Not Registered</em>'.html_safe
    end
  end

  def stage_link(stage)
    text, link = [TimelineEventType::STAGE_NAMES[stage], TimelineEventType::STAGE_LINKS[stage]]

    link_to link, target: '_blank' do
      "#{text} #{image_tag 'timeline/link.png'}".html_safe
    end
  end
end
