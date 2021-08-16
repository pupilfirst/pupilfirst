class SplitS3Buckets < ActiveRecord::Migration[6.1]
  def change
    old_bucket = Aws::S3::Bucket.new(Rails.application.secrets.aws[:bucket_public])
    new_bucket_key = Rails.application.secrets.aws[:bucket_private]
    date_of_transition = ENV['TEMP_DATE_OF_FILE_TRANSITION']
    skip_delete = ENV['TEMP_SKIP_DELETE']

    def copy_objects(scope)
      list = date_of_transition.present? scope.where('created_at > ?', Date.parse(date_of_transition).beginning_of_day : scope
      total_objects = list.count
      # Copy files
      list.each_with_index do |l, i|
        Rails.logger.info("Copying #{i}/#{total_objects}")
        object = old_bucket.object(l.file.blob.key)
        object.copy_to(
          bucket: new_bucket_key,
          key: l.file.blob.key
        )
        l.file.blob.update!(service_name: 'amazon_private')
      end

      return if date_of_transition.blank?
      # Update service name
      scope.where.not(blob: { service_name: 'amazon_private' }).each do |l|
        l.file.blob.update!(service_name: 'amazon_private')
      end
    end

    def delete_old_objects_and_update(scope)
      return if skip_delete

      total_objects = scope.count
      scope.each_with_index do |l, i|
        Rails.logger.info("Deleting #{i}/#{total_objects}")
        old_bucket.object.delete({})
      end
    end

    Rails.logger.info('Migrating Submission Files')
    copy_objects(TimelineEventFile.joins(file_attachment: :blob))

    Rails.logger.info('Migrating Course Exports')
    copy_objects(CourseExport.joins(file_attachment: :blob))

    Rails.logger.info('Deleting the copy of Submission Files')
    delete_old_objects(TimelineEventFile.joins(file_attachment: :blob))

    Rails.logger.info('Deleting the copy of Course Exports')
    delete_old_objects(CourseExport.joins(file_attachment: :blob))
  end
end
