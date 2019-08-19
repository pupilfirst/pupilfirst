module FacultyHelper
  def next_week_start
    7.days.from_now.beginning_of_week.in_time_zone('Asia/Calcutta').strftime('%b %d')
  end

  def next_week_end
    7.days.from_now.end_of_week.in_time_zone('Asia/Calcutta').strftime('%b %d')
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

  # rubocop:disable Rails/HelperInstanceVariable
  def past_connect_requests
    @faculty.past_connect_requests
  end

  def sidebar_present?(faculty)
    @sidebar_present ||= faculty.connect_slots.available_for_founder.exists? || past_connect_requests.exists?
  end

  def commitment_this_week
    commitment = @faculty.connect_slots.where(slot_at: Time.now.beginning_of_week..Time.now.end_of_week).count * 0.5
    return 'Unavailable' if commitment.zero?

    commitment_string = commitment >= 1 ? commitment.to_i.to_s : ''
    commitment_string += '½' if commitment.to_i != commitment
    commitment_string + (commitment > 1 ? ' hours' : ' hour')
  end

  def tooltip_for_commitment
    @faculty.commitment
  end

  def tooltip_for_compensation
    @faculty.compensation
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
