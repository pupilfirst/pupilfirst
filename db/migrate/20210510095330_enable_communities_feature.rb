class EnableCommunitiesFeature < ActiveRecord::Migration[6.0]
  def up
    Feature.create! key: 'communities', value: {active: 'admin'}.to_json
  end

  def down
    Feature.find_by(key: 'communities').destroy!
  end
end
