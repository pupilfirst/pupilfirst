[%bs.raw {|require("./FoundersList.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("FoundersList");

let make = (~founders, ~selectedFounderId, ~selectFounderCB, ~clearFounderCB, _children) => {
  ...component,
  render: _self =>
    <div className="founders-list__container">
      <div className="founders-list__header d-flex p-4 align-items-center justify-content-between">
        <h4 className="founders-list__header-title m-0 font-regular"> ("Your Students" |> str) </h4>
        <div className="founders-list__filter-btn-container">
          (
            switch (selectedFounderId) {
            | None => ReasonReact.null
            | Some(_id) =>
              <button className="founders-list__clear-filter-btn p-0" onClick=(_event => clearFounderCB())>
                ("Clear Filter" |> str)
              </button>
            }
          )
        </div>
      </div>
      (
        founders
        |> List.map(founder => {
             let buttonClasses =
               switch (selectedFounderId) {
               | None => "founders-list__item d-flex align-items-center"
               | Some(id) =>
                 id == (founder |> Founder.id) ?
                   "founders-list__item d-flex align-items-center founders-list__item--selected" :
                   "founders-list__item d-flex align-items-center"
               };
             <a
               className=buttonClasses
               key=(founder |> Founder.name)
               onClick=(_event => selectFounderCB(founder |> Founder.id))>
               <span className="founders-list__item-dp d-flex align-items-center p-1">
                 <img src=(founder |> Founder.avatarUrl) className="img-fluid" />
               </span>
               <span className="founders-list__item-details d-flex flex-column px-3">
                 <span className="founders-list__item-name"> (founder |> Founder.name |> str) </span>
               </span>
             </a>;
           })
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};
