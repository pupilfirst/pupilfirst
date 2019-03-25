[%bs.raw {|require("./FoundersList.scss")|}];

open CoachDashboard__Types;

let str = ReasonReact.string;

type state = string;

let component = ReasonReact.reducerComponent("FoundersList");

let founderButton = (selectedFounder, selectFounderCB, teamName, founder) => {
  let classes = "mt-2 founders-list__item d-flex align-items-center";

  let buttonClasses =
    switch (selectedFounder) {
    | None => classes
    | Some(selectedFounder) =>
      selectedFounder == founder ?
        classes ++ " founders-list__item--selected" : classes
    };

  <div
    className=buttonClasses
    key={founder |> Founder.name}
    onClick={_event => selectFounderCB(founder)}>
    <span className="founders-list__item-dp d-flex align-items-center">
      <img src={founder |> Founder.avatarUrl} className="img-fluid" />
    </span>
    <span className="founders-list__item-details d-flex flex-column px-3">
      <div> {founder |> Founder.name |> str} </div>
      {
        switch (teamName) {
        | Some(teamName) =>
          <div className="founders-list__team-name"> {teamName |> str} </div>
        | None => ReasonReact.null
        }
      }
    </span>
  </div>;
};

let allStudentsOptionClasses = selectedFounder => {
  let classes = "founders-list__item d-flex align-items-center pointer-cursor";

  switch (selectedFounder) {
  | None => classes ++ " founders-list__item--selected"
  | Some(_f) => classes
  };
};

let founderNameMatches = (searchString, founder) => {
  let re = Js.Re.fromStringWithFlags(searchString, ~flags="i");
  switch (founder |> Founder.name |> Js.String.match(re)) {
  | Some(_match) => true
  | None => false
  };
};

let make =
    (
      ~teams,
      ~founders,
      ~selectedFounder,
      ~selectFounderCB,
      ~clearFounderCB,
      _children,
    ) => {
  ...component,
  initialState: () => "",
  reducer: (searchString, _state: string) =>
    ReasonReact.Update(searchString),
  render: ({state, send}) =>
    <div className="founders-list__container py-3">
      <div
        className={allStudentsOptionClasses(selectedFounder)}
        onClick={_event => clearFounderCB()}>
        <span
          className="founders-list__item-details d-flex flex-row align-items-center pr-3">
          <span className="fa-stack founders-list__all-students-icon">
            <i className="fa fa-circle fa-stack-2x" />
            <i className="fa fa-inverse fa-users fa-stack-1x" />
          </span>
          <span className="pl-3"> {"All students" |> str} </span>
        </span>
      </div>
      <div
        className="founder-list__search-container d-flex align-items-center mt-2">
        <i className="fa fa-search mr-2" />
        <input
          type_="text"
          className="founder-list__search-input"
          placeholder="Search for a student"
          value=state
          onChange={event => send(event->ReactEvent.Form.target##value)}
        />
      </div>
      {
        teams
        |> List.map(team => {
             let foundersInTeam = founders |> Founder.inTeam(team);

             let filteredFounders =
               switch (state) {
               | "" => foundersInTeam
               | searchString =>
                 foundersInTeam
                 |> List.filter(founder =>
                      switch (selectedFounder) {
                      | Some(selectedFounder) =>
                        selectedFounder == founder ?
                          true : founder |> founderNameMatches(searchString)
                      | None => founder |> founderNameMatches(searchString)
                      }
                    )
               };

             let teamName =
               foundersInTeam |> List.length > 1 ?
                 Some(team |> Team.name) : None;

             filteredFounders
             |> List.map(founder =>
                  founder
                  |> founderButton(selectedFounder, selectFounderCB, teamName)
                )
             |> Array.of_list
             |> ReasonReact.array;
           })
        |> Array.of_list
        |> ReasonReact.array
      }
    </div>,
};