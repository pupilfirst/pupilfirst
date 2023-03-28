let str = React.string

let t = I18n.t(~scope="components.SubmissionChecklistShow")

@react.component
let make = (~checklist, ~updateChecklistCB) =>
  <div className="space-y-8">
    {ArrayUtils.isEmpty(checklist)
      ? <div> {t("target_marked_as_complete")->str} </div>
      : checklist
        ->Js.Array2.mapi((checklistItem, index) =>
          <SubmissionChecklistItemShow
            key={string_of_int(index)} index checklistItem updateChecklistCB checklist
          />
        )
        ->React.array}
  </div>
