[@bs.config {jsx: 3}];

open StudentsPanel__Types;

type teamCoachlist = (string, string, bool);

type view =
  | DetailsTab
  | ActionsTab;

let str = ReasonReact.string;

let selectedTabClasses = selected => {
  "flex items-center justify-center w-1/2 p-3 font-semibold rounded-t-lg leading-relaxed border border-gray-400 text-gray-600 cursor-pointer "
  ++ (selected ? "text-primary-500 bg-white border-b-0" : "bg-gray-100");
};

[@react.component]
let make =
    (
      ~student,
      ~isSingleFounder,
      ~teams,
      ~studentTags,
      ~teamCoachIds,
      ~courseCoachIds,
      ~schoolCoaches,
      ~submitFormCB,
      ~authenticityToken,
    ) => {
  let (view, setView) = React.useState(() => DetailsTab);
  <div className="mx-auto bg-white">
    <div className="pt-6 pl-16 mb-4 border-b bg-gray-100">
      <div className="flex items-centre">
        {switch (student |> Student.avatarUrl) {
         | Some(avatarUrl) =>
           <img className="w-12 h-12 rounded-full mr-4" src=avatarUrl />
         | None =>
           <Avatar name={student |> Student.name} className="w-12 h-12 mr-4" />
         }}
        <div className="text-sm flex flex-col justify-center">
          <div className="text-black font-bold inline-block">
            {student |> Student.name |> str}
          </div>
          <div className="text-gray-600 inline-block">
            {student |> Student.email |> str}
          </div>
        </div>
      </div>
      <div className="w-full pt-6">
        <ul
          className="flex flex-wrap w-full max-w-3xl mx-auto text-sm px-3 -mb-px">
          <li
            className={selectedTabClasses(view == DetailsTab)}
            onClick={_ => setView(_ => DetailsTab)}>
            <span className="ml-2"> {"Add Content" |> str} </span>
          </li>
          <li
            className={selectedTabClasses(view == ActionsTab)}
            onClick={_ => setView(_ => ActionsTab)}>
            <span className="ml-2"> {"Method of Completion" |> str} </span>
          </li>
        </ul>
      </div>
    </div>
    <div className="max-w-2xl p-6 mx-auto">
      {switch (view) {
       | DetailsTab =>
         <SA_StudentsPanel_UpdateDetailsForm
           student
           isSingleFounder
           teams
           studentTags
           teamCoachIds
           courseCoachIds
           schoolCoaches
           submitFormCB
           authenticityToken
         />
       | ActionsTab =>
         <SA_StudentsPanel_ActionsForm
           student
           isSingleFounder
           teams
           studentTags
           teamCoachIds
           courseCoachIds
           schoolCoaches
           submitFormCB
           authenticityToken
         />
       }}
    </div>
  </div>;
};
