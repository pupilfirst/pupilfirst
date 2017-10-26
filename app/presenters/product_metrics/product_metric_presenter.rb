module ProductMetrics
  class ProductMetricPresenter < ApplicationPresenter
    def initialize(view_context, metric)
      @metric = metric
      super(view_context)
    end

    def key
      return ProductMetrics::IndexPresenter::PROGRAM_METRICS[@metric] if ProductMetrics::IndexPresenter::PROGRAM_METRICS.key?(@metric)
      raise "Cannot resolve icon for metric '#{@metric}'"
    end

    def heading
      view.t("product_metrics.index.product_metric.#{key}.heading")
    end

    def description
      view.t("product_metrics.index.product_metric.#{key}.description_html")
    end

    def delta_verb
      view.t("product_metrics.index.product_metric.#{key}.delta_verb")
    end

    def icon_key
      key.to_s.tr('_', '-')
    end
  end
end
