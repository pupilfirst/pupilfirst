module ProductMetrics
  class CollectForIndexService
    # Return all metrics
    def metrics
      ProductMetric::VALID_CATEGORIES.each_with_object({}) do |category, metrics|
        metrics[category] = load_metric(category)
      end.with_indifferent_access
    end

    private

    def load_metric(category)
      product_metric = ProductMetric.where(category: category).order(created_at: :desc).first

      if product_metric.present?
        product_metric.slice(:value, :delta_period, :delta_value)
      else
        { value: 0 }
      end
    end
  end
end
