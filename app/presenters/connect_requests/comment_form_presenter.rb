module ConnectRequests
  class CommentFormPresenter < ApplicationPresenter
    def initialize(view_context, rating)
      @rating = rating
      super(view_context)
    end

    def connect_request_rating_stars
      rating_solid_star = @rating.to_i
      rating_regular_star = 5 - rating_solid_star

      # Add solid stars.
      stars_html = (1..rating_solid_star).map { |_r| '<i class="fa fa-star"></i>' }

      # Add regular stars, if rating is below 5
      stars_html << (1..rating_regular_star).map { |_r| '<i class="fa fa-star-o"></i>' }

      # Return as HTML.
      stars_html.join("\n").html_safe
    end
  end
end
