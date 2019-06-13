[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

let linkToCommunity = (communityId, targetId) =>
  "/communities/" ++ communityId ++ "?target_id=" ++ targetId;

let linkToNewQuestion = (communityId, targetId) =>
  "/communities/"
  ++ communityId
  ++ "/questions/new"
  ++ "?target_id="
  ++ targetId;

let questionCard = question => {
  let questionId = question |> Community.questionId;
  let questionLink = "/questions/" ++ questionId;
  <div
    href=questionLink
    key=questionId
    className="flex justify-between items-center p-3 bg-gray-300 shadow-sm rounded-lg mb-2">
    <span className="w-3/4">
      {question |> Community.questionTitle |> str}
    </span>
    <a href=questionLink className="btn btn-default"> {"View" |> str} </a>
  </div>;
};

let handleEmpty = () =>
  <div className="flex flex-col justify-center items-center p-3">
    <i
      className="target-overlay-community__empty-icon text-5xl mb-2 fa fa-comments"
    />
    <div className="target-overlay-community__empty-text text-center">
      <h5 className="font-semibold"> {"There's no one here yet." |> str} </h5>
      <p>
        {
          "This is where you'll see all the discussion activity happening on this target."
          |> str
        }
      </p>
    </div>
  </div>;

let actionButtons = (communityId, targetId) =>
  <div className="flex">
    <a
      href={linkToCommunity(communityId, targetId)}
      className="target-overlay-community__button-default btn btn-default btn-sm mr-3">
      {React.string("Go to community")}
    </a>
    <a
      href={linkToNewQuestion(communityId, targetId)}
      className="btn btn-secondary btn-sm">
      {React.string("Ask a question")}
    </a>
  </div>;

let communityTitle = community =>
  <h4 className="m-0 pull-left font-semibold">
    {"Questions from " ++ (community |> Community.name) ++ " community" |> str}
  </h4>;

[@react.component]
let make = (~target, ~targetDetails) => {
  let communities = targetDetails |> TargetDetails.communities;
  let targetId = target |> Target.id;
  <div className="flex justify-center w-full">
    <div className="w-full max-w-3xl">
      {
        communities
        |> List.map(community => {
             let communityId = community |> Community.id;
             <div key=communityId className="mt-12">
               <div className="flex w-full justify-between pb-3">
                 <div className="target-overlay-community_title">
                   {communityTitle(community)}
                 </div>
                 {actionButtons(communityId, targetId)}
               </div>
               <div className="justify-between">
                 {
                   switch (community |> Community.questions) {
                   | [] => handleEmpty()
                   | questions =>
                     questions
                     |> List.map(question => questionCard(question))
                     |> Array.of_list
                     |> React.array
                   }
                 }
               </div>
             </div>;
           })
        |> Array.of_list
        |> React.array
      }
    </div>
  </div>;
};