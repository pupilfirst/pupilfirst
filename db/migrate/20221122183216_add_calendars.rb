class AddCalendars < ActiveRecord::Migration[6.1]
  def change
    create_table :calendars do |t|
      t.references :course
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table :calendar_events do |t|
      t.string :title
      t.text :description
      t.references :calendar
      t.string :color
      t.datetime :start_time
      t.datetime :end_time
      t.string :link_url
      t.string :link_title
      t.timestamps
    end

    create_table :calendar_cohorts do |t|
      t.references :calendar
      t.references :cohort
    end
  end
end
