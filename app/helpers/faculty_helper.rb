module FacultyHelper
  def faculty_image_path(type, image)
    # Images are stored in a subfolder in faculty/
    path = "faculty/#{type}/#{image}"

    # Remove Salutations
    path.gsub!('Dr. ', '')

    # Convert initials and spaces to underscores
    path.tr!('. ', '_')

    # Convert to underscore case
    path = path.underscore

    # Convert multiple underscores to one
    path.gsub!(/_+/, '_')

    # PNG image
    path + '.png'
  end

  def next_week_start
    7.days.from_now.beginning_of_week.in_time_zone('Asia/Calcutta').strftime('%b %d')
  end

  def next_week_end
    7.days.from_now.end_of_week.in_time_zone('Asia/Calcutta').strftime('%b %d')
  end

  def active_tab(name)
    @active_tab == name ? 'active' : nil
  end

  def faculty_rating_stars(rating)
    # Round rating to nearest .5, or .0.
    rating = ((rating * 2).round / 2.0)

    # Add full stars.
    stars_html = (1..rating).map { |_r| '<i class="fa fa-star"></i>' }

    # Add half star, if any.
    stars_html << '<i class="fa fa-star-half-o"></i>' if rating.to_i != rating

    # Return as HTML.
    stars_html.join("\n").html_safe
  end
end
