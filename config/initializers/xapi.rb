require "pupilfirst_xapi"

PupilfirstXapi.repository = ->(klass, resource_id) {
  klass.to_s.camelize.constantize.find(resource_id)
}

PupilfirstXapi.uri_for = ->(obj) {
  url_helpers = Rails.application.routes.url_helpers
  case obj
  when Course
    url_helpers.course_url(obj, host: obj.school.domains.primary.fqdn)
  when Target
    url_helpers.target_url(obj, host: obj.course.school.domains.primary.fqdn)
  else
    raise RuntimeError.new("Unable to determinne URI for #{obj.class}")
  end
}
