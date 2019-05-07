[@bs.config {jsx: 3}];

[@react.component]
let make = (~questions, ~targetId, ~loading, ~communityPath) =>
  <div className="target-overlay__container mx-auto">
    <div className="target-overlay-content-block__header-container clearfix">
      <h5
        className="target-overlay-content-block__header m-0 pull-left font-semibold">
        {React.string("Questions from community")}
      </h5>
    </div>
    <a
      href={communityPath ++ "/?target_id=" ++ (targetId |> string_of_int)}
      className="btn btn-primary">
      {React.string("Show Community")}
    </a>
    {
      loading ?
        <div> {React.string("Loading")} </div> :
        questions |> Array.length > 0 ?
          questions
          |> Array.map(question =>
               <div key={question##id |> string_of_int} className="pb-3">
                 <div
                   className="d-flex border border-primary p-2 justify-content-between">
                   <div className=""> {React.string(question##title)} </div>
                   <a
                     href={"/questions/" ++ (question##id |> string_of_int)}
                     className="btn btn-primary">
                     {React.string("Click Me")}
                   </a>
                 </div>
               </div>
             )
          |> ReasonReact.array :
          <div> {React.string("Empty List")} </div>
    }
  </div>;