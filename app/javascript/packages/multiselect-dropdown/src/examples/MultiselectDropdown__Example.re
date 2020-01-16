[@bs.config {jsx: 3}];

let str = React.string;

module DetailedExample = {
  module Identifier = {
    type t =
      | City
      | State
      | Country
      | Search;
  };

  module Multiselect = MultiselectDropdown.Make(Identifier);

  type selection = {
    identifier: Identifier.t,
    item: string,
  };

  type state = {
    searchInput: string,
    selected: array(selection),
  };

  let makeSelectableCity = city => {
    Multiselect.Selectable.make(
      ~label="City",
      ~item=city,
      ~color="orange",
      ~searchString="city " ++ city,
      ~identifier=City,
      (),
    );
  };

  let makeSelectableState = state => {
    Multiselect.Selectable.make(
      ~label="State",
      ~item=state,
      ~color="green",
      ~searchString="state " ++ state,
      ~identifier=State,
      (),
    );
  };

  let makeSelectableCounty = country => {
    Multiselect.Selectable.make(
      ~label="Country",
      ~item=country,
      ~color="blue",
      ~searchString="Country " ++ country,
      ~identifier=Country,
      (),
    );
  };

  let makeSelectableSearch = searchInput => {
    Multiselect.Selectable.make(
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

  let unselected = searchInput => {
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

  let updateSelection = (setState, selectable) => {
    let selection = {
      identifier: selectable |> Multiselect.Selectable.identifier,
      item: selectable |> Multiselect.Selectable.item,
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
             |> Multiselect.Selectable.identifier == s.identifier
             && selectable
             |> Multiselect.Selectable.item == s.item
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
    <div className="mt-4">
      <h2 className="text-xl font-semibold"> {"Detailed Example" |> str} </h2>
      <div className="mt-4">
        <label
          className="block text-xs font-semibold"
          htmlFor="MultiselectDropdown__search-input-detailed-example">
          {"Filter by:" |> str}
        </label>
      </div>
      <Multiselect
        unselected={unselected(state.searchInput)}
        selected={selected(state.selected)}
        updateSelectionCB={updateSelection(setState)}
        clearSelectionCB={clearSelection(state.selected, setState)}
        value={state.searchInput}
        onChange={updateSearchInput(setState)}
        placeholder="Type city, state or country"
      />
    </div>;
  };
};

module MinimalExample = {
  module Identifier = {
    type t =
      | City(code)
      | Country(code)
    and code = int;
  };

  // create a Multiselect
  module Multiselect = MultiselectDropdown.Make(Identifier);

  type state = {
    selected: array(Multiselect.Selectable.t),
    searchString: string,
  };

  let unselected = [|
    Multiselect.Selectable.make(~item="Delhi", ~identifier=City(1), ()),
    Multiselect.Selectable.make(~item="India", ~identifier=Country(91), ()),
    Multiselect.Selectable.make(
      ~item="Washington D.C",
      ~identifier=City(2),
      (),
    ),
    Multiselect.Selectable.make(~item="USA", ~identifier=Country(1), ()),
  |];

  let clearSelection = (selected, setState, selectable) => {
    let newSelected = selected |> Js.Array.filter(s => s == selectable);
    setState(_ => {searchString: "", selected: newSelected});
  };

  [@react.component]
  let make = () => {
    let (state, setState) =
      React.useState(() => {searchString: "", selected: [||]});
    <div className="mt-4">
      <h2 className="text-xl font-semibold"> {"Minimal Example" |> str} </h2>
      <div className="mt-4">
        <label
          className="block text-xs font-semibold"
          htmlFor="MultiselectDropdown__search-input">
          {"Filter by:" |> str}
        </label>
      </div>
      <Multiselect
        unselected
        selected={state.selected}
        updateSelectionCB={selectable =>
          setState(s =>
            {
              searchString: "",
              selected: s.selected |> Array.append([|selectable|]),
            }
          )
        }
        clearSelectionCB={clearSelection(state.selected, setState)}
        value={state.searchString}
        onChange={searchString => setState(s => {...s, searchString})}
      />
    </div>;
  };
};

ReactDOMRe.renderToElementWithId(<DetailedExample />, "DetailedExample");
ReactDOMRe.renderToElementWithId(<MinimalExample />, "MinimalExample");
