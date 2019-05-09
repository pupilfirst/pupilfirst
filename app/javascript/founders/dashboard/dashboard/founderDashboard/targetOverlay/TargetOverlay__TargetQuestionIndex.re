[@bs.config {jsx: 3}];

[@react.component]
let make =
    (
      ~questions,
      ~targetId,
      ~loading,
      ~communityPath,
      ~new_community_question_path,
    ) =>
  <div className="target-overlay-community__container mx-auto">
    <div className="d-flex justify-content-between align-items-center pb-3">
      <div className="">
        <h4
          className="target-overlay-content-block__header m-0 pull-left font-semibold">
          {React.string("Questions from community")}
        </h4>
      </div>
      <div>
        <a
          href={communityPath ++ "/?target_id=" ++ (targetId |> string_of_int)}
          className="btn btn-default btn-sm mr-3 mb-2 md:mb-0">
          {React.string("Go to community")}
        </a>
        <a href="" className="btn btn-secondary btn-sm">
          {React.string("Ask a question")}
        </a>
      </div>
    </div>
    {
      loading ?
        <div
          className="target-overlay-community__loading shadow-sm rounded-lg p-3 text-center text-uppercase d-flex flex-column justify-content-center align-items-center">
          <i
            className="target-overlay-community__loading-icon fa fa-spinner fa-spin"
          />
          <div className="mt-2">
            <h5 className="font-semibold"> {React.string("Loading...")} </h5>
          </div>
        </div> :
        <div
          className="target-overlay-community__question-container shadow-sm rounded-lg">
          {
            questions |> Array.length > 0 ?
              questions
              |> Array.map(question =>
                   <a
                     href={"/questions/" ++ (question##id |> string_of_int)}
                     key={question##id |> string_of_int}
                     className="target-overlay-community__question d-flex justify-content-between text-dark align-items-center border-bottom border-grey p-3">
                     <p> {React.string(question##title)} </p>
                     <a
                       href={"/questions/" ++ (question##id |> string_of_int)}
                       className="btn btn-default btn-sm font-weight-normal">
                       {React.string("Click to view")}
                     </a>
                   </a>
                 )
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
              </div>
          }
        </div>
    }
  </div>;