module HomeHelper
  def activity_class_for_count(count)
    if count.zero?
      'activity-blank'
    elsif count <= 5
      'activity-low'
    elsif count <= 10
      'activity-medium'
    else
      'activity-high'
    end
  end

  def startup_village_redirect?
    params[:redirect_from] == 'startupvillage.in'
  end

  def university_count_from_applications
    Rails.cache.fetch('home/university_count', expires_in: 1.hour) do
      University.joins(:founders).distinct.count
    end
  end
end
