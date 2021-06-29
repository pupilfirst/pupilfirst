let str = React.string

@react.component
let make = (~checklist, ~updateChecklistCB, ~pending) =>
  <div>
    {ArrayUtils.isEmpty(checklist)
      ? <div> {"Target was marked as complete."->str} </div>
      : Array.mapi(
          (index, checklistItem) =>
            <SubmissionChecklistItemShow
              key={string_of_int(index)} index checklistItem updateChecklistCB checklist pending
            />,
          checklist,
        )->React.array}
  </div>
