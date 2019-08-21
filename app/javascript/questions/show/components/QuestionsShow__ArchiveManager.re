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
    (authenticityToken, id, resourceType, archiveCB, setSaving, event) =>
  Webapi.Dom.window
  |> Webapi.Dom.Window.confirm(
       "Are you sure you want to delete this "
       ++ (resourceType |> Js.String.toLowerCase)
       ++ ". You cannot undo this.",
     ) ?
    {
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
    } :
    ();

[@react.component]
let make = (~authenticityToken, ~id, ~resourceType, ~archiveCB) => {
  let (saving, setSaving) = React.useState(() => false);
  <a
    title={"Archive " ++ resourceType}
    onClick={
      archive(authenticityToken, id, resourceType, archiveCB, setSaving)
    }
    className="flex items-center justify-center whitespace-no-wrap text-xs font-semibold py-1 px-3 flex-shrink-0 bg-transparent text-red-400 hover:bg-red-100 hover:text-red-800 cursor-pointer">
    {
      saving ?
        <FaIcon classes="fas fa-spinner fa-spin" /> :
        <FaIcon classes="fas fa-trash-alt" />
    }
    {
      resourceType == "Comment" ?
        React.null : <span className="ml-1"> {"Delete" |> str} </span>
    }
  </a>;
};
