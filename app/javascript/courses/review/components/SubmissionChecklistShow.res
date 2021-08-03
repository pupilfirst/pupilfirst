let str = React.string

let t = I18n.t(~scope="components.SubmissionChecklistShow")

@react.component
let make = (~checklist, ~updateChecklistCB, ~pending) =>
  <div className="space-y-8">
    {ArrayUtils.isEmpty(checklist)
      ? <div> {t("target_marked_as_complete")->str} </div>
      : Array.mapi(
          (index, checklistItem) =>
            <SubmissionChecklistItemShow
              key={string_of_int(index)} index checklistItem updateChecklistCB checklist pending
            />,
          checklist,
        )->React.array}
  </div>
