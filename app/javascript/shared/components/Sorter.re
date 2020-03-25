let str = React.string;
module type Sortable = {
  type t;
  let criterion: t => string;
  let criterionType: t => [ | `String | `Number];
};

module Make = (Sortable: Sortable) => {
  let dropdown = (criteria, selectedCriterion, onCriterionChange) => {
    let selectedForDropdown =
      <button
        title={"Order by " ++ (selectedCriterion |> Sortable.criterion)}
        className="inline-flex items-center bg-white leading-relaxed font-semibold border border-gray-400 rounded focus:outline-none focus:bg-white focus:border-gray-500 px-3 py-2 text-xs ">
        <span className="ml-2">
          {selectedCriterion |> Sortable.criterion |> str}
        </span>
        <i className="fas fa-caret-down ml-3" />
      </button>;
    let dropDownContents =
      criteria
      |> Js.Array.filter(criterion =>
           Sortable.criterion(criterion)
           != Sortable.criterion(selectedCriterion)
         )
      |> Array.map(criterion => {
           <button
             key={Sortable.criterion(criterion)}
             title={"Order by " ++ Sortable.criterion(criterion)}
             onClick={_ => onCriterionChange(criterion)}
             className="inline-flex items-center w-full font-semibold text-xs p-3 text-left focus:outline-none ">
             <Icon
               className="if i-clock-regular text-sm if-fw text-gray-700"
             />
             <span className="ml-2">
               {Sortable.criterion(criterion) |> str}
             </span>
           </button>
         });
    <Dropdown selected=selectedForDropdown contents=dropDownContents />;
  };

  let directionIconClasses = (criterionType, direction) => {
    switch (criterionType, direction) {
    | (`String, `Up) => "fas fa-sort-alpha-down"
    | (`String, `Down) => "fas fa-sort-alpha-down-alt"
    | (`Number, `Up) => "fas fa-sort-amount-up-alt"
    | (`Number, `Down) => "fas fa-sort-amount-down-alt"
    };
  };

  [@react.component]
  let make =
      (
        ~criteria,
        ~selectedCriterion,
        ~direction,
        ~onDirectionChange,
        ~onCriterionChange,
      ) => {
    <div className="flex items-center">
      {criteria |> Array.length > 1
         ? dropdown(criteria, selectedCriterion, onCriterionChange)
         : <div
             title={"Order by " ++ (selectedCriterion |> Sortable.criterion)}
             className="inline-flex items-center bg-white leading-relaxed font-semibold border border-gray-400 rounded focus:outline-none focus:bg-white focus:border-gray-500 px-3 py-2 text-xs ">
             <span className="ml-2">
               {selectedCriterion |> Sortable.criterion |> str}
             </span>
           </div>}
      {<span className="bg-white p-1 border border-gray-400 ml-1 rounded">
         {switch (direction) {
          | `Up =>
            <button onClick={_ => onDirectionChange(`Down)}>
              <FaIcon
                classes={directionIconClasses(
                  Sortable.criterionType(selectedCriterion),
                  `Up,
                )}
              />
            </button>
          | `Down =>
            <button onClick={_ => onDirectionChange(`Up)}>
              <FaIcon
                classes={directionIconClasses(
                  Sortable.criterionType(selectedCriterion),
                  `Down,
                )}
              />
            </button>
          }}
       </span>}
    </div>;
  };
};
