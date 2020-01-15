[@bs.config {jsx: 3}];

module Example = {
  let str = React.string;

  module Identifier = {
    type t =
      | City
      | State
      | Country
      | Search;
  };

  module ReMultiselect = ReMultiselect.Make(Identifier);

  type selection = {
    identifier: Identifier.t,
    item: string,
  };

  type state = {
    searchInput: string,
    selected: array(selection),
  };

  let makeSelectableCity = city => {
    ReMultiselect.Selectable.make(
      ~label="City",
      ~item=city,
      ~color="orange",
      ~searchString="city " ++ city,
      ~identifier=City,
      (),
    );
  };

  let makeSelectableState = state => {
    ReMultiselect.Selectable.make(
      ~label="State",
      ~item=state,
      ~color="green",
      ~searchString="state " ++ state,
      ~identifier=State,
      (),
    );
  };

  let makeSelectableCounty = country => {
    ReMultiselect.Selectable.make(
      ~label="Country",
      ~item=country,
      ~color="blue",
      ~searchString="Country " ++ country,
      ~identifier=Country,
      (),
    );
  };

  let makeSelectableSearch = searchInput => {
    ReMultiselect.Selectable.make(
      ~label="Search",
      ~item=searchInput,
      ~color="purple",
      ~searchString=searchInput,
      ~identifier=Search,
      (),
    );
  };

  let selected = selected => {
    selected
    |> Array.map(selection => {
         switch (selection.identifier) {
         | City => makeSelectableCity(selection.item)
         | State => makeSelectableState(selection.item)
         | Country => makeSelectableCounty(selection.item)
         | Search => makeSelectableSearch(selection.item)
         }
       });
  };

  let selections = searchInput => {
    let citySuggestions =
      [|"Chicago", "San Francisco", "Los Angeles"|]
      |> Array.map(t => makeSelectableCity(t));

    let stateSuggestions =
      [|"Washington", "California", "Mississippi"|]
      |> Array.map(l => makeSelectableState(l));

    let countrySuggestions =
      [|"India", "USA", "Canada"|] |> Array.map(l => makeSelectableCounty(l));

    let searchSuggestion =
      searchInput |> Js.String.trim == ""
        ? [||] : [|makeSelectableSearch(searchInput)|];

    searchSuggestion
    |> Array.append(citySuggestions)
    |> Array.append(stateSuggestions)
    |> Array.append(countrySuggestions);
  };

  let updateFilter = (setSearchInput, updateFilterCB, filter) => {
    updateFilterCB(filter);
    setSearchInput(_ => "");
  };

  let updateSelection = (setState, selectable) => {
    let selection = {
      identifier: selectable |> ReMultiselect.Selectable.identifier,
      item: selectable |> ReMultiselect.Selectable.item,
    };

    setState(s =>
      {searchInput: "", selected: [|selection|] |> Array.append(s.selected)}
    );
  };

  let clearSelection = (selected, setState, selectable) => {
    let newSelected =
      selected
      |> Js.Array.filter(s =>
           !(
             selectable
             |> ReMultiselect.Selectable.identifier == s.identifier
             && selectable
             |> ReMultiselect.Selectable.item == s.item
           )
         );
    setState(_ => {searchInput: "", selected: newSelected});
  };

  let updateSearchInput = (setState, searchInput) => {
    setState(s => {...s, searchInput});
  };

  [@react.component]
  let make = () => {
    let (state, setState) =
      React.useState(() => {searchInput: "", selected: [||]});
    <div className="max-w-md w-full mx-auto p-6">
      <h1 className="text-center text-2xl font-bold">
        {"re-multiselect" |> str}
      </h1>
      <div className="mt-4">
        <label
          className="block text-xs font-semibold"
          htmlFor="reMultiselect__search-input">
          {"Filter by:" |> str}
        </label>
      </div>
      <ReMultiselect
        unselected={selections(state.searchInput)}
        selected={selected(state.selected)}
        updateSelectionCB={updateSelection(setState)}
        clearSelectionCB={clearSelection(state.selected, setState)}
        value={state.searchInput}
        onChange={updateSearchInput(setState)}
      />
    </div>;
  };
};

ReactDOMRe.renderToElementWithId(<Example />, "root");
