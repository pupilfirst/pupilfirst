---
id: upgrading
title: Upgrading Guide
sidebar_label: Upgrading
---

## Run Migrations

When deploying changes from `master` branch, please check for any pending [migrations](https://edgeguides.rubyonrails.org/active_record_migrations.html)
and run them after deployment.

## Breaking changes

These are a list of changes that should be accounted for when upgrading an existing installation of Pupilfirst. If you
encounter any problems while following these instructions, please [create a new issue](https://github.com/pupilfirst/pupilfirst/issues/new)
on our Github repo.

Your current version can be found in `Pupilfirst::Application::VERSION`.

### 2021.4

Introduced support for public and private file storage. Its now mandatory to have two bucket's for storage, one public and one private linked to the app.

#### Migration Steps

<!-- Improve documentation -->

1. Convert the current bucket that you are using to a public bucket and create a new private bucket.
2. Rename the env variable `AWS_BUCKET` to `AWS_BUCKET_PUBLIC`.
3. Add a new environment variable `AWS_BUCKET_PRIVATE`, this should be the private bucket name. (New Bucket)
4. Deploy and run the migration.

#### Steps for configuring public access settings for your S3 bucket

Amazon S3 Block Public Access feature provides settings to help you manage public access to Amazon S3 resources. By default, new buckets and objects do not allow public access.
You can use the S3 console or AWS CLI to configure public access settings for your bucket. 

For information on configuring public access to your S3 storage, please refer to the documentation [here](https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-block-public-access-bucket.html)

#### Creating S3 private bucket
When you create a new bucket through the AWS S3 console, the default setting in set permissions is _Block all public access_.

Refer to this documentation on [creating a new S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

#### Steps for a migrating with a shorter downtime (optional)

If you want to complete the migration with a shorter downtime you will need to split the deployment into three steps.

1. _Pre-deployment_: Copy the files till a specific date to the new bucket before migration
2. _Deployment_: Setup downtime and deploy code which will migrate the rest of the files.
3. _Post-deployment_: Cleanup the files from the old bucket

##### Additional Steps

1. Add a new environment variable `TEMP_DATE_OF_FILE_TRANSITION`, the variable will store date in `dd/mm/yyyy` format
2. Add a new environment variable `TEMP_SKIP_DELETE` that will ensure that files are not purged as part of the migration.
3. Run the following script from your terminal and copy the files till a specific date to the new private bucket.

   ```ruby
   # The files from start till the date mentioned will be copied to the new private bucket. Format dd/mm/yyyy
   @old_bucket = Aws::S3::Bucket.new('public_bucket_key')
   @new_bucket_key = 'private_bucket_key'
   @date_of_transition = '16/08/2021'

   def copy_objects(scope, table_name)
     list =
       scope.where(
         "#{table_name}.created_at < ?",
         Date.parse(@date_of_transition).beginning_of_day,
       )
     total_objects = list.count

     list.each_with_index do |l, i|
       Rails.logger.info("Copying #{i}/#{total_objects}")
       key = l.file.blob.key
       object = @old_bucket.object(key)
       object.copy_to(bucket: @new_bucket_key, key: key)
     end
   end

   Rails.logger.info('Migrating Submission Files')
   copy_objects(
     TimelineEventFile.joins(file_attachment: :blob),
     'timeline_event_files',
   )

   Rails.logger.info('Migrating Course Exports')
   copy_objects(CourseExport.joins(file_attachment: :blob), 'course_exports')
   ```

4. Follow the _Migration Steps_ mentioned above.
5. Run the following code after migration and purge the old files.

   ```ruby
   def delete_old_objects_and_update(scope)
     total_objects = scope.count
     scope.each_with_index do |l, i|
       Rails.logger.info("Deleting #{i}/#{total_objects}")
       object = @old_bucket.object(l.file.blob.key)
       object.delete({})
     end
   end

   Rails.logger.info('Deleting the copy of Submission Files')
   delete_old_objects(TimelineEventFile.joins(file_attachment: :blob))

   Rails.logger.info('Deleting the copy of Course Exports')
   delete_old_objects(CourseExport.joins(file_attachment: :blob))
   ```

### 2021.3

- Google's Recaptcha has been introduced to protect public-facing forms from automation.
  To enable the use of Recaptcha, [register for access](https://www.google.com/recaptcha),
  and create v3 and v2 (checkbox) keys for your school's domains, and add environment variables
  `RECAPTCHA_V3_SITE_KEY`, `RECAPTCHA_V3_SECRET_KEY`, `RECAPTCHA_V2_SITE_KEY`, and `RECAPTCHA_V2_SECRET_KEY`.

### 2021.2

- List `courses` query is now paginated. This will affect users using the `courses` api.

### 2021.1

- Introduced required environment variable `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` to support
  webpush notification.

  You can generate the keys by running the following on the server.

  ```
  vapid_key = Webpush.generate_key

  #VAPID_PUBLIC_KEY
  vapid_key.public_key

  #VAPID_PRIVATE_KEY
  vapid_key.private_key
  ```

### 2020.4

- Introduced required environment variable `GRAPH_API_RATE_LIMIT`, `MEMCACHEDCLOUD_SERVERS`, `MEMCACHEDCLOUD_USERNAME`,
  `MEMCACHEDCLOUD_PASSWORD` to handle API rate limiting. Memcached Cloud add-on needs to be added while hosting on Heroku.

### 2020.3

- Introduced required environment variable `DEFAULT_SENDER_EMAIL_ADDRESS`. Prior to this, the default sender email id
  was assumed to be `noreply@pupilfirst.com`.

### 2020.2

- Introduced required environment variable `AWS_REGION`. Prior to this, the region was assumed to be `us-east-1`; set
  the correct value for your S3 bucket.

### 2020.1

- Initial release.
