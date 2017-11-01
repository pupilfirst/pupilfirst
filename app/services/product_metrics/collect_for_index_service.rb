module ProductMetrics
  class CollectForIndexService
    # Return all metrics
    def metrics
      ProductMetric::VALID_CATEGORIES.keys.each_with_object({}) do |category, metrics|
        metrics[category] = load_metric(category)
      end.with_indifferent_access
    end

    private

    def load_metric(category)
      product_metric = ProductMetric.where(category: category).order(created_at: :desc).first

      if product_metric.present?
        { value: product_metric.value }.merge(delta(product_metric))
      else
        { value: 0 }
      end
    end

    def delta(product_metric)
      # If the delta period is blank, we don't show delta.
      return {} if product_metric.delta_period.blank?

      # If the delta value is stored, it doesn't need to be computed. Just return stored values.
      return product_metric.slice(:delta_value, :delta_period) if product_metric.delta_value.present?

      # Compute the delta value.
      { delta_value: delta_value(product_metric), delta_period: product_metric.delta_period }
    end

    def delta_value(product_metric)
      oldest_metric_in_period = ProductMetric.where(category: product_metric.category)
        .where('created_at > ?', product_metric.created_at - product_metric.delta_period.months)
        .order(created_at: :asc).first

      product_metric.value - oldest_metric_in_period.value
    end
  end
end
