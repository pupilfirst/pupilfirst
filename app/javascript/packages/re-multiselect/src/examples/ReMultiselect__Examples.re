module Example = {
  let str = React.string;

  module Identifier = {
    type t =
      | Name
      | Flower
      | CartoonCharacter;
  };

  module ReMultiselect2 = ReMultiselect2.Make(Identifier);

  type selection = {
    identifier: Identifier.t,
    item: string,
  };

  type state = {
    searchInput: string,
    selected: array(selection),
  };

  let makeSelectableFlower = flower => {
    ReMultiselect2.Selectable.make(
      ~label="Flower",
      ~item=flower,
      ~color="yellow",
      ~searchString="flower " ++ flower,
      ~identifier=Identifier.Flower,
      (),
    );
  };

  let makeSelectableCartoonCharacter = character => {
    ReMultiselect2.Selectable.make(
      ~label="Character",
      ~item=character,
      ~color="green",
      ~searchString="character " ++ character,
      ~identifier=CartoonCharacter,
      (),
    );
  };

  let makeSelectableSearch = searchInput => {
    ReMultiselect2.Selectable.make(
      ~label="Name",
      ~item=searchInput,
      ~color="purple",
      ~searchString=searchInput,
      ~identifier=Name,
      (),
    );
  };

  let selected = selected => {
    selected
    |> Array.map(selection => {
         switch (selection.identifier) {
         | Name => makeSelectableSearch(selection.item)
         | Flower => makeSelectableFlower(selection.item)
         | CartoonCharacter => makeSelectableCartoonCharacter(selection.item)
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
      identifier: selectable |> ReMultiselect2.Selectable.identifier,
      item: selectable |> ReMultiselect2.Selectable.item,
    };

    setState(s =>
      {searchInput: "", selected: [|selection|] |> Array.append(s.selected)}
    );
  };

  let clearSelection = (selected, setState, selectable) => {
    ()// let newSelected =
      //   selected
      //   |> Js.Array.filter(s =>
      //        !(
      //          selectable
      //          |> Selectable.selectable == s.selectable
      //          && selectable
      //          |> Selectable.item == s.item
      ; //      );
 //        )
      // setState(s => {searchInput: "", selected: newSelected});
  };

  let updateSearchInput = (setState, searchInput) => {
    setState(s => {...s, searchInput});
  };

  [@react.component]
  let make = () => {
    let (state, setState) =
      React.useState(() => {searchInput: "", selected: [||]});

    <ReMultiselect2
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
