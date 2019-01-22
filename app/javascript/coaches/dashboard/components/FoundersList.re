[%bs.raw {|require("./FoundersList.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("FoundersList");

let founderButtons = (selectedFounder, selectFounderCB, founders) =>
  founders
  |> List.map(founder => {
       let buttonClasses =
         switch (selectedFounder) {
         | None => "founders-list__item d-flex align-items-center"
         | Some(selectedFounder) =>
           selectedFounder == founder ?
             "founders-list__item d-flex align-items-center founders-list__item--selected" :
             "founders-list__item d-flex align-items-center"
         };
       <div className=buttonClasses key=(founder |> Founder.name) onClick=(_event => selectFounderCB(founder))>
         <span className="founders-list__item-dp d-flex align-items-center p-1">
           <img src=(founder |> Founder.avatarUrl) className="img-fluid" />
         </span>
         <span className="founders-list__item-details d-flex flex-column px-3">
           <span className="founders-list__item-name"> (founder |> Founder.name |> str) </span>
         </span>
       </div>;
     })
  |> Array.of_list
  |> ReasonReact.array;

let make = (~teams, ~founders, ~selectedFounder, ~selectFounderCB, ~clearFounderCB, _children) => {
  ...component,
  render: _self =>
    <div className="founders-list__container">
      <div className="founders-list__header d-flex align-items-center justify-content-between">
        <h4 className="founders-list__header-title m-0 font-regular">
          <i className="fa fa-filter mr-1" />
          ("Filter by student:" |> str)
        </h4>
        <div className="founders-list__filter-btn-container">
          (
            switch (selectedFounder) {
            | None => ReasonReact.null
            | Some(_founder) =>
              <div className="founders-list__clear-filter-btn p-0" onClick=(_event => clearFounderCB())>
                ("Clear" |> str)
              </div>
            }
          )
        </div>
      </div>
      (
        teams
        |> List.map(team => {
             let foundersInTeam = founders |> Founder.inTeam(team);
             if (foundersInTeam |> List.length > 1) {
               <div className="founders-list__team-container" key=(team |> Team.id |> string_of_int)>
                 <div className="founders-list__team-name font-semibold"> (team |> Team.name |> str) </div>
                 (foundersInTeam |> founderButtons(selectedFounder, selectFounderCB))
               </div>;
             } else {
               <div className="mb-3"> (foundersInTeam |> founderButtons(selectedFounder, selectFounderCB)) </div>;
             };
           })
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};
