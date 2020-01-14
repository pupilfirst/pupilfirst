module Example = {
  let str = React.string;

  module ResourceType = {
    type t =
      | Name
      | Flower
      | CartoonCharacter;
  };

  module Selectable = ReMultiselect__Selectable.Make(ResourceType);

  type selection = {
    resourceType: ResourceType.t,
    item: string,
  };

  type state = {
    searchInput: string,
    selected: array(selection),
  };

  let makeSelectableFlower = flower => {
    Selectable.make(
      ~label=Some("Flower"),
      ~item=flower,
      ~color="yellow",
      ~searchString="flower " ++ flower,
      ~resourceType=Flower,
      (),
    );
  };

  let makeSelectableCartoonCharacter = character => {
    Selectable.make(
      ~label=Some("Character"),
      ~item=character,
      ~color="green",
      ~searchString="character " ++ character,
      ~resourceType=CartoonCharacter,
      (),
    );
  };

  let makeSelectableSearch = searchInput => {
    Selectable.make(
      ~label=Some("Name"),
      ~item=searchInput,
      ~color="purple",
      ~searchString=searchInput,
      ~resourceType=Name,
      (),
    );
  };

  let selected = selected => {
    selected
    |> Array.map(filter => {
         switch (filter.resourceType) {
         | Name => makeSelectableSearch(filter.item)
         | Flower => makeSelectableFlower(filter.item)
         | CartoonCharacter => makeSelectableCartoonCharacter(filter.item)
         }
       });
  };

  let selections = searchInput => {
    let cartoonCharacterSuggestions =
      [|"Mickey Mouse", "Donald Duck", "Popeye", "Bufs Bunny"|]
      |> Array.map(t => makeSelectableCartoonCharacter(t));

    let flowerSuggestions =
      [|"Rose", "Sunflowe", "Jasmine"|]
      |> Array.map(l => makeSelectableFlower(l));

    let searchSuggestion =
      searchInput |> Js.String.trim == ""
        ? [||] : [|makeSelectableSearch(searchInput)|];

    searchSuggestion
    |> Array.append(cartoonCharacterSuggestions)
    |> Array.append(flowerSuggestions);
  };

  let updateFilter = (setSearchInput, updateFilterCB, filter) => {
    updateFilterCB(filter);
    setSearchInput(_ => "");
  };

  let updateSelection = (setState, selectable) => {
    let selection = {
      resourceType: selectable |> Selectable.resourceType,
      item: selectable |> Selectable.item,
    };

    setState(s =>
      {searchInput: "", selected: [|selection|] |> Array.append(s.selected)}
    );
  };

  let clearSelection = (selected, setState, selectable) => {
    ()//   |> Js.Array.filter(s =>
      //        !(
      //          selectable
      //          |> Selectable.resourceType == s.resourceType
      //          && selectable
      //          |> Selectable.item == s.item
      //        )
      //      );
      ; //   selected
 // let newSelected =
      // setState(s => {searchInput: "", selected: newSelected});
  };

  let updateSearchInput = (setState, searchInput) => {
    setState(s => {...s, searchInput});
  };

  [@react.component]
  let make = () => {
    let (state, setState) =
      React.useState(() => {searchInput: "", selected: [||]});

    <ReMultiselect
      unselected={selections(state.searchInput)}
      selected={selected(state.selected)}
      updateSelectionCB={updateSelection(setState)}
      clearSelectionCB={clearSelection(state.selected, setState)}
      value={state.searchInput}
      onChange={updateSearchInput(setState)}
    />;
  };
};

ReactDOMRe.renderToElementWithId(<Example />, "root");
