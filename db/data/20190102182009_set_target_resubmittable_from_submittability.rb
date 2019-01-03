class SetTargetResubmittableFromSubmittability < ActiveRecord::Migration[5.2]
  def up
    Target.all.each do |target|
      next if target.submittability.blank?
      if target.submittability == 'resubmittable'
        target.update!(resubmittable: true)
      else
        target.update!(resubmittable: false)
      end
    end
  end

  def down
    Target.update_all(resubmittable: nil)
  end
end
