let str = React.string
module type Sortable = {
  type t
  let criterion: t => string
  let criterionType: t => [#String | #Number]
}

let t = I18n.t(~scope="components.Sorter", ...)

module Make = (Sortable: Sortable) => {
  let dropdown = (criteria, selectedCriterion, onCriterionChange) => {
    let selectedForDropdown =
      <button
        ariaLabel={t("order_by") ++ " " ++ Sortable.criterion(selectedCriterion)}
        title={t("order_by") ++ " " ++ Sortable.criterion(selectedCriterion)}
        className="flex w-full items-center justify-between leading-relaxed font-semibold bg-white border border-gray-300 rounded focus:outline-none px-2 md:px-3 py-1 md:py-2 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 ">
        <span> {str(Sortable.criterion(selectedCriterion))} </span>
        <i className="fas fa-caret-down ms-3" />
      </button>
    let dropDownContents = Array.map(criterion =>
      <button
        key={Sortable.criterion(criterion)}
        ariaLabel={t("order_by") ++ " " ++ Sortable.criterion(criterion)}
        title={t("order_by") ++ " " ++ Sortable.criterion(criterion)}
        onClick={_ => onCriterionChange(criterion)}
        className="inline-flex items-center w-full font-semibold whitespace-nowrap text-xs p-3  focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 ">
        <Icon className="if i-clock-regular text-sm if-fw text-gray-600" />
        <span className="ms-2"> {str(Sortable.criterion(criterion))} </span>
      </button>
    , Js.Array.filter(
      criterion => Sortable.criterion(criterion) != Sortable.criterion(selectedCriterion),
      criteria,
    ))
    <Dropdown selected=selectedForDropdown contents=dropDownContents />
  }

  let directionIconClasses = (criterionType, direction) =>
    switch (criterionType, direction) {
    | (#String, #Ascending) => "if i-sort-alpha-ascending-regular w-4 if-fw"
    | (#String, #Descending) => "if i-sort-alpha-descending-regular w-4 if-fw"
    | (#Number, #Ascending) => "if i-sort-numeric-ascending-regular w-4 if-fw"
    | (#Number, #Descending) => "if i-sort-numeric-descending-regular w-4 if-fw"
    }

  @react.component
  let make = (~criteria, ~selectedCriterion, ~direction, ~onDirectionChange, ~onCriterionChange) =>
    <div className="flex">
      {Array.length(criteria) > 1
        ? dropdown(criteria, selectedCriterion, onCriterionChange)
        : <div
            title={t("order_by") ++ " " ++ Sortable.criterion(selectedCriterion)}
            className="inline-flex flex-1 md:flex-auto items-center bg-gray-50 leading-relaxed font-semibold text-gray-600 border border-gray-300 rounded px-3 py-1 md:py-2 text-sm ">
            <div> {str(Sortable.criterion(selectedCriterion))} </div>
          </div>}
      <span className="flex ms-1">
        <button
          ariaLabel={t("toggle_sort")}
          title="toggle-sort-order"
          className="bg-white w-10 px-2 py-1 rounded border border-gray-300 text-gray-800 hover:bg-gray-50 hover:text-primary-500 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 "
          onClick={_ => {
            let swappedDirection = switch direction {
            | #Ascending => #Descending
            | #Descending => #Ascending
            }
            onDirectionChange(swappedDirection)
          }}>
          <Icon
            className={directionIconClasses(Sortable.criterionType(selectedCriterion), direction)}
          />
        </button>
      </span>
    </div>
}
