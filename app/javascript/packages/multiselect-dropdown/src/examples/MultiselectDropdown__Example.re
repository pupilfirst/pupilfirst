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
    value: string,
  };

  type state = {
    searchInput: string,
    selected: array(selection),
  };

  let makeSelectableCity = city => {
    Multiselect.Selectable.make(
      ~label="City",
      ~value=city,
      ~color="orange",
      ~searchString="city " ++ city,
      ~identifier=City,
      (),
    );
  };

  let makeSelectableState = state => {
    Multiselect.Selectable.make(
      ~label="State",
      ~value=state,
      ~color="green",
      ~searchString="state " ++ state,
      ~identifier=State,
      (),
    );
  };

  let makeSelectableCounty = country => {
    Multiselect.Selectable.make(
      ~label="Country",
      ~value=country,
      ~color="blue",
      ~searchString="Country " ++ country,
      ~identifier=Country,
      (),
    );
  };

  let makeSelectableSearch = searchInput => {
    Multiselect.Selectable.make(
      ~label="Search",
      ~value=searchInput,
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
         | City => makeSelectableCity(selection.value)
         | State => makeSelectableState(selection.value)
         | Country => makeSelectableCounty(selection.value)
         | Search => makeSelectableSearch(selection.value)
         }
       });
  };

  let unselected = searchInput => {
    let citySuggestions =
      [|
        "Chicago",
        "San Francisco",
        "Los Angeles",
        "Busan",
        "Jerusalem",
        "Bangalore",
        "Cochin",
        "Chennai",
      |]
      |> Array.map(t => makeSelectableCity(t));

    let stateSuggestions =
      [|
        "Washington",
        "California",
        "Mississippi",
        "Kuala Lumpur",
        "Kerala",
        "Karnataka",
        "Tamil Nadu",
      |]
      |> Array.map(l => makeSelectableState(l));

    let countrySuggestions =
      [|"India", "USA", "Canada", "China", "Japan", "Egypt", "Korea"|]
      |> Array.map(l => makeSelectableCounty(l));

    let searchSuggestion =
      searchInput |> Js.String.trim == ""
        ? [||] : [|makeSelectableSearch(searchInput)|];

    searchSuggestion
    |> Array.append(citySuggestions)
    |> Array.append(stateSuggestions)
    |> Array.append(countrySuggestions);
  };

  let select = (setState, selectable) => {
    let selection = {
      identifier: selectable |> Multiselect.Selectable.identifier,
      value: selectable |> Multiselect.Selectable.value,
    };

    setState(s =>
      {searchInput: "", selected: [|selection|] |> Array.append(s.selected)}
    );
  };

  let deselect = (selected, setState, selectable) => {
    let newSelected =
      selected
      |> Js.Array.filter(s =>
           !(
             selectable
             |> Multiselect.Selectable.identifier == s.identifier
             && selectable
             |> Multiselect.Selectable.value == s.value
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
        selectCB={select(setState)}
        deselectCB={deselect(state.selected, setState)}
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
    Multiselect.Selectable.make(~value="Delhi", ~identifier=City(1), ()),
    Multiselect.Selectable.make(~value="India", ~identifier=Country(91), ()),
    Multiselect.Selectable.make(
      ~value="Washington D.C",
      ~identifier=City(2),
      (),
    ),
    Multiselect.Selectable.make(~value="USA", ~identifier=Country(1), ()),
  |];

  let deselect = (selected, setState, selectable) => {
    let newSelected = selected |> Js.Array.filter(s => s != selectable);
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
        selectCB={selectable =>
          setState(s =>
            {
              searchString: "",
              selected: [|selectable|] |> Array.append(s.selected),
            }
          )
        }
        deselectCB={deselect(state.selected, setState)}
        value={state.searchString}
        onChange={searchString => setState(s => {...s, searchString})}
      />
    </div>;
  };
};

ReactDOMRe.renderToElementWithId(<DetailedExample />, "DetailedExample");
ReactDOMRe.renderToElementWithId(<MinimalExample />, "MinimalExample");
