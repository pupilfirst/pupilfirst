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
    className="flex justify-between items-center px-5 py-4 bg-white border-t">
    <span className="text-sm font-semibold">
      {question |> Community.questionTitle |> str}
    </span>
    <a href=questionLink className="btn btn-primary-ghost btn-small">
      {"View" |> str}
    </a>
  </div>;
};

let handleEmpty = () =>
  <div
    className="flex flex-col justify-center items-center bg-white px-3 py-10">
    <i className="fa fa-comments text-5xl text-gray-600 mb-2 " />
    <div className="text-center">
      <h4 className="font-bold"> {"There's no one here yet." |> str} </h4>
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
      className="btn btn-default mr-3">
      {React.string("Go to community")}
    </a>
    <a
      href={linkToNewQuestion(communityId, targetId)}
      className="btn btn-primary">
      {React.string("Ask a question")}
    </a>
  </div>;

let communityTitle = community =>
  <h5 className="font-bold">
    {"Questions from " ++ (community |> Community.name) ++ " community" |> str}
  </h5>;

[@react.component]
let make = (~target, ~targetDetails) => {
  let communities = targetDetails |> TargetDetails.communities;
  let targetId = target |> Target.id;
  <div className="">
    {
      communities
      |> List.map(community => {
           let communityId = community |> Community.id;
           <div
             key=communityId
             className="mt-12 bg-gray-100 px-6 py-4 rounded-lg">
             <div
               className="flex flex-col md:flex-row w-full justify-between pb-3 items-center">
               <div> {communityTitle(community)} </div>
               {actionButtons(communityId, targetId)}
             </div>
             <div
               className="justify-between rounded-lg overflow-hidden shadow">
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
  </div>;
};