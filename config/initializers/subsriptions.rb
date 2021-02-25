{
  :student_added => [
    Keycloak::SetupStudentAccount.new
  ],
}
.each do |event_type, subscribers|
  subscribers.each do |subscriber|
    ActiveSupport::Notifications.subscribe("#{event_type}.pupilfirst") do |_, _, _, _, payload|
      subscriber.call(**payload)
    end
  end
end
