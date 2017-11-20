require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding product metrics'

  ProductMetric::VALID_CATEGORIES.keys.each do |category|
    metric = ProductMetric.new(category: category, value: rand(100))
    metric.assignment_mode = if ProductMetric::VALID_CATEGORIES[category][:automatic]
      ProductMetric::ASSIGNMENT_MODE_AUTOMATIC
    else
      ProductMetric::ASSIGNMENT_MODE_MANUAL
    end
    metric.faculty = Faculty.team.sample if metric.assignment_mode == ProductMetric::ASSIGNMENT_MODE_MANUAL
    metric.delta_period = ProductMetric::VALID_CATEGORIES[category][:delta_period]
    metric.delta_value = rand(10) if metric.delta_period

    metric.save!
  end
end
