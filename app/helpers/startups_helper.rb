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
    text, link = case stage
      when TimelineEventType::TYPE_STAGE_IDEA
        ['Idea discovery', 'http://playbook.sv.co/stages/5.1-idea-discovery.html']
      when TimelineEventType::TYPE_STAGE_PROTOTYPE
        ['Prototyping', 'http://playbook.sv.co/stages/5.2-prototyping.html']
      when TimelineEventType::TYPE_STAGE_CUSTOMER
        ['Customer Validation', 'http://playbook.sv.co/stages/5.3-customer-validation.html']
      when TimelineEventType::TYPE_STAGE_EFFICIENCY
        ['Efficiency', 'http://playbook.sv.co/stages/5.4-efficiency.html']
      when TimelineEventType::TYPE_STAGE_SCALE
        ['Scale', 'http://playbook.sv.co/stages/5.5-scale.html']
      else
        # This shouldn't ever actually appear.
        ['Unknown', '#']
    end

    link_to link, target: '_blank' do
      "#{text} #{image_tag 'timeline/link.png'}".html_safe
    end
  end
end
