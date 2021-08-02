Flipper::UI.configure do |config|
  config.descriptions_source = ->(_) do
    Rails.application.config_for(:features)
  end
  config.show_feature_description_in_list = true
end

Flipper.register(:admins) do |actor|
  User === actor.thing && AdminUser.exists?(user_id: actor.id)
end

Flipper.register(:school_admins) do |actor|
  User === actor.thing && SchoolAdmin.exists?(user_id: actor.id)
end

Flipper.register(:course_authors) do |actor|
  User === actor.thing && CourseAuthor.exists?(user_id: actor.id)
end