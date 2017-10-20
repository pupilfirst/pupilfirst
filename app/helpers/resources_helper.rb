module ResourcesHelper
  def zero_results_text
    login_text = current_founder.blank? ? "or #{link_to 'logging in', new_user_session_path, rel: 'nofollow'} to unlock private resources" : ''

    t('resources.index.zero_results', tag_text: tag_text, search_text: search_text, login_text: login_text)
  end

  def results_caption
    t('resources.index.results_caption', tag_text: tag_text, search_text: search_text)
  end

  def tag_text
    return if params[:resources_filter].blank?
    tags = params[:resources_filter][:tags] - ['']
    tags.present? ? "tagged with \'#{tags.join(', ')}\'" : ''
  end

  def search_text
    return if params[:resources_filter].blank?
    params[:resources_filter][:search].present? ? "whose title contains \'#{params[:resources_filter][:search].downcase}\'" : ''
  end

  def date_filter_options
    ['Since Yesterday', 'Past Week', 'Past Month', 'Past Year']
  end
end
