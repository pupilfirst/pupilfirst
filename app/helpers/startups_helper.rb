module StartupsHelper
  def encode_startup_id

  end

  def decode_startup_id

  end

  def incorporation_status_html(registration_type)
    case registration_type
      when Startup::REGISTRATION_TYPE_PARTNERSHIP
        'Partnership'
      when Startup::REGISTRATION_TYPE_PRIVATE_LIMITED
        'Private Limited'
      when Startup::REGISTRATION_TYPE_LLP
        'Limited Liability Partnership'
      else
        '<em>Not Incorporated</em>'.html_safe
    end
  end

  def revenue_generated_html(revenue_generated)
    case revenue_generated
      when nil
        '<em>Nothing yet</em>'.html_safe
      when ''
        '<em>Nothing yet</em>'.html_safe
      else
        revenue_generated
    end
  end

  def product_progress_html(product_progress)
    case product_progress
      when Startup::PRODUCT_PROGRESS_IDEA
        'Just an idea'
      when Startup::PRODUCT_PROGRESS_MOCKUP
        'Mockups'
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

  def presentation_html(presentation_link)
    if presentation_link.present?
      link_to presentation_link, presentation_link
    else
      '<em>Not Available</em>'.html_safe
    end
  end

  def website_html(website_link)
    if website_link.present?
      link_to website_link, website_link
    else
      '<em>Not Available</em>'.html_safe
    end
  end

  def social_media_html(facebook_link, twitter_link)
    response = ''

    if @startup.facebook_link.present?
      response += link_to 'Facebook', @startup.facebook_link
    end

    if @startup.twitter_link.present?
      response += ', ' if @startup.facebook_link.present?
      response += link_to 'Twitter', @startup.twitter_link
    end

    response.html_safe
  end

  def logo_image_html(thumb_url)
    if thumb_url
      image_tag thumb_url
    else
      '<em>Not Available</em>'.html_safe
    end
  end

  def about_html(about)
    if about
      simple_format about
    else
      '<em>Not Available</em>'.html_safe
    end
  end
end
