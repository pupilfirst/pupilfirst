class RemoveLevelZeroFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :startups, :pitch
    remove_column :startups, :registration_type
    remove_column :startups, :product_description
    remove_column :startups, :state
    remove_column :startups, :district
    remove_column :startups, :product_progress
    remove_column :startups, :presentation_link
    remove_column :startups, :pin
    remove_column :startups, :metadata
    remove_column :startups, :stage
    remove_column :startups, :wireframe_link
    remove_column :startups, :prototype_link
    remove_column :startups, :product_video_link
    remove_column :startups, :program_started_on
    remove_column :startups, :courier_name
    remove_column :startups, :courier_number
    remove_column :startups, :admission_stage
    remove_column :startups, :timeline_updated_on
    remove_column :startups, :admission_stage_updated_at
    remove_column :startups, :referral_reward_days
    remove_column :startups, :facebook_link
    remove_column :startups, :twitter_link
    remove_column :startups, :website
    remove_column :startups, :address
  end
end
