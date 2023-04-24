module FlipperHelper
  def with_features(*features)
    Flipper.features.each(&:remove)
    features.each { |feature| Flipper[feature.to_sym].enable }
    yield
  ensure
    Flipper.features.each(&:remove)
  end
end
