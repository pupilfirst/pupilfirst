[@bs.config {jsx: 3}];

let levelUpImage: string = [%raw "require('../images/level-up.svg')"];

open CourseShow__Types;

let str = React.string;

module LevelUpQuery = [%graphql
  {|
   mutation($courseId: ID!) {
    levelUp(courseId: $courseId){
      success
      }
    }
 |}
];

let handleSubmitButton = saving => {
  let submitButtonText = (title, iconClasses) =>
    <span> <FaIcon classes={iconClasses ++ " mr-2"} /> {title |> str} </span>;

  saving ?
    submitButtonText("Saving", "fal fa-spinner-third fa-spin") :
    submitButtonText("Level Up", "fas fa-pennant");
};

let refreshPage = () => Webapi.Dom.(location |> Location.reload);

let createLevelUpQuery = (authenticityToken, course, setSaving, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  LevelUpQuery.make(~courseId=course |> Course.id, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##levelUp##success ? refreshPage() : setSaving(_ => false);
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~course, ~authenticityToken) => {
  let (saving, setSaving) = React.useState(() => false);
  <div
    className="max-w-3xl mx-auto text-center mt-4 bg-white rounded-lg shadow-lg p-6">
    <img className="w-20 mx-auto" src=levelUpImage />
    <div className="font-semibold text-2xl">
      {"Ready to Level Up!" |> str}
    </div>
    <div className="text-sm max-w-xl mx-auto">
      {
        "Congratulations! You have successfully completed all milestone targets required to level up. Click the button below to proceed to the next level. New challenges await!"
        |> str
      }
    </div>
    <button
      disabled=saving
      onClick={createLevelUpQuery(authenticityToken, course, setSaving)}
      className="btn btn-success mt-4">
      {handleSubmitButton(saving)}
    </button>
  </div>;
};