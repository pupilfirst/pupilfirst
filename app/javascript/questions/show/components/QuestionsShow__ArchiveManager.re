[@bs.config {jsx: 3}];

let str = React.string;

module ArchiveQuery = [%graphql
  {|
   mutation($id: ID!, $resourceType: String!) {
    archiveCommunityResource(id: $id, resourceType: $resourceType){
       success
     }
   }
 |}
];

let archive =
    (authenticityToken, id, resourceType, archiveCB, setSaving, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  ArchiveQuery.make(~id, ~resourceType, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##archiveCommunityResource##success ?
         {
           Notification.success(
             "Success",
             resourceType ++ " archived successfully",
           );
           archiveCB(id, resourceType);
         } :
         Notification.error(
           "Something went wrong",
           "Please refresh the page and try again",
         );
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~authenticityToken, ~id, ~resourceType, ~archiveCB) => {
  let (saving, setSaving) = React.useState(() => false);
  <a
    title={"Archive " ++ resourceType}
    onClick={
      archive(authenticityToken, id, resourceType, archiveCB, setSaving)
    }
    className="text-sm px-2 font-semibold cursor-pointer">
    {
      saving ?
        <FaIcon classes="fal fa-spinner-third fa-spin" /> : "Delete" |> str
    }
  </a>;
};