[@bs.config {jsx: 3}];

module ChecklistItem = SubmissionChecklistItem;

let str = React.string;

[@react.component]
let make = (~checklist, ~updateChecklistCB) => {
  <div>
    {checklist
     |> Array.mapi((index, checklistItem) => {
          <SubmissionChecklistItemShow
            key={index |> string_of_int}
            index
            checklistItem
            updateChecklistCB
            checklist
          />
        })
     |> React.array}
  </div>;
};
