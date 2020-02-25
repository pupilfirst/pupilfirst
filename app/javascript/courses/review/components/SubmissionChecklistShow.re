[@bs.config {jsx: 3}];

module ChecklistItem = SubmissionChecklistItem;

let str = React.string;

[@react.component]
let make = (~checklist, ~updateChecklistCB, ~pending) => {
  <div>
    {switch (checklist) {
     | [||] => <div> {"Target was marked as complete." |> str} </div>
     | _checlist =>
       checklist
       |> Array.mapi((index, checklistItem) => {
            <SubmissionChecklistItemShow
              key={index |> string_of_int}
              index
              checklistItem
              updateChecklistCB
              checklist
              pending
            />
          })
       |> React.array
     }}
  </div>;
};
