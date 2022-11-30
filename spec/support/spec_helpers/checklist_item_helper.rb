module ChecklistItemHelper
  def checklist_item(kind, result)
    {
      'kind' => kind,
      'title' => Faker::Lorem.sentence,
      'result' => result,
      'status' => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    }
  end
end
