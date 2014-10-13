module MentoringHelper
  def company_level_label(product_progress)
    case product_progress
      when Startup::PRODUCT_PROGRESS_IDEA
        'Idea stage'
      when Startup::PRODUCT_PROGRESS_MOCKUP
        'Mockup stage'
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
end
