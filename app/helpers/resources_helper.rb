module ResourcesHelper
  def zero_results_text
    login_text = current_founder.blank? ? "or #{link_to 'logging in', new_founder_session_path} to unlock private resources" : ''

    t('resource.search_results.zero_results', tag_text: tag_text, search_text: search_text, login_text: login_text)
  end

  def results_caption
    t('resource.search_results.results_caption', tag_text: tag_text, search_text: search_text)
  end

  def tag_text
    params[:tags].present? ? "tagged with \'#{params[:tags].join(', ')}\'" : ''
  end

  def search_text
    params[:search].present? ? "whose title contains \'#{params[:search].titlecase}\'" : ''
  end
end
