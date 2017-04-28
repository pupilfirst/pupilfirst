class AddStartupIterationDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :startups, :iteration, from: nil, to: 1
  end
end
