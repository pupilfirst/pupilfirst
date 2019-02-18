class MigrateFilesFromCarrierWavetoActiveStorage < ActiveRecord::Migration[5.2]
  def up
    # Migrate Founder#avatar
    Founder.where.not(avatar: nil).each do |founder|
      founder.avatar_as.attach(io: open(founder.avatar.url), filename: founder.avatar.file.path.split('/').last, content_type:  founder.avatar.file.content_type)
    end

    # Migrate Faculty#image
    Faculty.where.not(image: nil).each do |faculty|
      faculty.image_as.attach(io: open(faculty.image.url), filename: faculty.image.file.path.split('/').last, content_type:  faculty.image.file.content_type)
    end

    # Migrate TimelineEventFile#file

    TimelineEventFile.where.not(file: nil).each do |te_file|
      te_file.file_as.attach(io: open(te_file.file.url), filename: te_file.file.path.split('/').last, content_type:  te_file.file.file.content_type)
    end

    # Migrate Resource#file

    Resource.where.not(file: nil).each do |resource|
      resource.file_as.attach(io: open(resource.file.url), filename: resource.file.path.split('/').last, content_type:  resource.file.file.content_type)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
