class V1::CategoriesController < V1::BaseController
  skip_before_filter :require_token

  def index
    @categories = if(params[:category_type])
      Category.where(category_type: params[:category_type])
    else
      Category.all
    end
  end
end
