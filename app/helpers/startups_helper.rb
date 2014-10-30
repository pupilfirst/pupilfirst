module StartupsHelper
  def encode_startup_id

  end

  def decode_startup_id

  end

  def user_is_startup_founder(startup)
    return false unless current_user
    current_user.is_founder? && current_user.startup_id == startup.id
  end

  def about_html(about)
    if about.present?
      simple_format about
    else
      "<em>This startup hasn't filled in anything about themselves yet.</em>".html_safe
    end
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

  def nil_not_available(value, output_simple_format: false)
    case value
      when nil
        '<em>Not Available</em>'.html_safe
      else
        if output_simple_format
          simple_format value
        else
          value
        end
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

  def categories_html(categories)
    if categories.empty?
      '<em>None Selected</em>'.html_safe
    else
      categories.map(&:name).join(', ')
    end
  end

  def link_html(link)
    if link.present?
      link_to link, link
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
      image_tag thumb_url, class: 'img-responsive startup-logo', alt: 'Startup Logo'
    end
  end

  def incubation_location_html(incubation_location)
    if incubation_location
      incubation_location.capitalize
    else
      '<em>Not Available</em>'.html_safe
    end
  end
end
