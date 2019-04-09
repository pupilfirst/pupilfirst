open CommunityDashboard__Types;

/*
 module CoursesQuery = [%graphql
   {|
   query {
     courses{
       id
       name
       endsAt
       maxGrade
       passGrade
       gradesAndLabels {
         grade
         label
       }
     }
   }
 |}
 ]; */

type editorAction =
  | Hidden
  | ShowForm(option(Question.t));

type state = {
  editorAction,
  questions: list(Question.t),
};

type action =
  | UpdateEditorAction(editorAction);

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CommunityDashboard");

let make = (~authenticityToken, ~questions, _children) => {
  ...component,
  initialState: () => {editorAction: Hidden, questions},
  reducer: (action, state) =>
    switch (action) {
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    },
  /* didMount: ({send}) => {
       let coursesQuery = CoursesQuery.make();
       let response = coursesQuery |> GraphqlQuery.sendQuery(authenticityToken);
       response
       |> Js.Promise.then_(result => {
            let courses =
              result##courses
              |> Js.Array.map(rawCourse => {
                   let endsAt =
                     switch (rawCourse##endsAt) {
                     | Some(endsAt) => Some(endsAt |> Json.Decode.string)
                     | None => None
                     };
                   let gradesAndLabels =
                     rawCourse##gradesAndLabels
                     |> Array.map(gradesAndLabel =>
                          GradesAndLabels.create(
                            gradesAndLabel##grade,
                            gradesAndLabel##label,
                          )
                        )
                     |> Array.to_list;

                   Course.create(
                     rawCourse##id |> int_of_string,
                     rawCourse##name,
                     endsAt,
                     rawCourse##maxGrade,
                     rawCourse##passGrade,
                     gradesAndLabels,
                   );
                 })
              |> Array.to_list;
            send(UpdateCourses(courses));
            Js.Promise.resolve();
          })
       |> ignore;
     }, */
  render: ({state, send}) =>
    <div className="flex flex-1 h-screen bg-grey-lighter overflow-y-scroll">
      <div className="flex-1 flex flex-col">
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            className="max-w-md w-full flex mx-auto items-center justify-center relative bg-grey-lighter hover:bg-grey-light hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-20 cursor-pointer">
            <i className="material-icons"> {"add_circle_outline" |> str} </i>
            <h4 className="font-semibold ml-2">
              {"Ask a new question" |> str}
            </h4>
          </button>
        </div>
        <div className="px-6 pb-4 mt-5 flex flex-1">
          <div className="max-w-md w-full mx-auto relative">
            {
              state.questions
              |> Question.sort
              |> List.map(question =>
                   <div
                     className="flex items-center shadow bg-white rounded-lg mb-4">
                     <div
                       className="flex w-full"
                       key={question |> Question.id |> string_of_int}>
                       <a
                         className="cursor-pointer flex flex-1 items-center py-4 px-4 hover:bg-grey-lighter">
                         <div className="text-sm">
                           <span className="text-black font-semibold">
                             {question |> Question.title |> str}
                           </span>
                         </div>
                       </a>
                     </div>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </div>
        </div>
      </div>
    </div>,
};