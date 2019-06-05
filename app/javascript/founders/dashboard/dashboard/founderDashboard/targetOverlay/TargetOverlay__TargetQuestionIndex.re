[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~questions, ~targetId, ~communities, ~loading) =>
  <div className="target-overlay-community__container mx-auto">
    {
      loading ?
        <div
          className="target-overlay-community__loading shadow-sm rounded-lg p-3 text-center text-uppercase d-flex flex-column justify-content-center align-items-center">
          <i
            className="target-overlay-community__loading-icon fa fa-spinner fa-spin"
          />
          <div className="mt-2">
            <h5 className="font-semibold"> {"Loading..." |> str} </h5>
          </div>
        </div> :
        <div>
          {
            communities
            |> Array.map(community =>
                 <div key=community##id className="mt-2">
                   <div
                     className="target-overlay-community_header d-flex justify-content-between pb-3">
                     <div className="target-overlay-community_title">
                       <h4 className="m-0 pull-left font-semibold">
                         {
                           "Questions from "
                           ++
                           community##name
                           ++ " community"
                           |> str
                         }
                       </h4>
                     </div>
                     <div className="row">
                       <a
                         href={
                           "/communities/"
                           ++
                           community##id
                           ++ "?target_id="
                           ++ (targetId |> string_of_int)
                         }
                         className="target-overlay-community__button-default btn btn-default btn-sm mr-3">
                         {React.string("Go to community")}
                       </a>
                       <a
                         href={
                           "/communities/"
                           ++
                           community##id
                           ++ "/questions/new"
                           ++ "?target_id="
                           ++ (targetId |> string_of_int)
                         }
                         className="btn btn-secondary btn-sm">
                         {React.string("Ask a question")}
                       </a>
                     </div>
                   </div>
                   <div
                     className="target-overlay-community__question-container shadow-sm rounded-lg">
                     {
                       let questionsForCommunity =
                         questions
                         |> Array.to_list
                         |> List.filter(question =>
                              question##communityId == community##id
                            );

                       questionsForCommunity |> List.length > 0 ?
                         questionsForCommunity
                         |> List.map(question =>
                              <a
                                href={
                                  "/questions/"
                                  ++ (question##id |> string_of_int)
                                }
                                key={question##id |> string_of_int}
                                className="target-overlay-community__question d-flex justify-content-between text-600 align-items-center border-bottom border-grey p-3">
                                <span className="d-block col-12 col-sm-9">
                                  {React.string(question##title)}
                                </span>
                                <a
                                  href={
                                    "/questions/"
                                    ++ (question##id |> string_of_int)
                                  }
                                  className="target-overlay-community__question-view-btn btn btn-default btn-sm font-weight-normal">
                                  {React.string("View")}
                                </a>
                              </a>
                            )
                         |> Array.of_list
                         |> ReasonReact.array :
                         <div
                           className="target-overlay-community__empty py-3 px-3 d-flex flex-column justify-content-center align-items-center">
                           <i
                             className="target-overlay-community__empty-icon mb-2 fa fa-comments"
                           />
                           <div
                             className="target-overlay-community__empty-text text-center">
                             <h5 className="font-semibold">
                               {React.string("There's no one here yet.")}
                             </h5>
                             <p>
                               {
                                 React.string(
                                   "This is where you'll see all the discussion activity happening on this target.",
                                 )
                               }
                             </p>
                           </div>
                         </div>;
                     }
                   </div>
                 </div>
               )
            |> React.array
          }
        </div>
    }
  </div>;