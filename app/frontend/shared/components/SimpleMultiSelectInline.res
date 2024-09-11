type item = {
  id: string,
  name: string,
}

type state = {
  selected: array<item>,
  searchInput: string
}

type action =
  | SelectItem(item)
  | DeSelectItem(item)
  | UpdateSearchInput(string)

let reducer = (state, action) =>
  switch action {
  | UpdateSearchInput(searchInput) => {...state, searchInput: searchInput}
  | SelectItem(item) => {
      ...state,
      selected: Js.Array2.concat(state.selected, [item]),
    }
  | DeSelectItem(item) => {
      ...state,
      selected: state.selected->Js.Array2.filter(i =>
       i.id != item.id
      ),
    }
  }

module SelectableItem = {
  type t = item

  let value = t => t.name
  let searchString = value
}

module Multiselect = MultiselectInline.Make(SelectableItem)

let unselectedItems = (allItems, selected) => {
  allItems->Js.Array2.filter(item => Js.Array2.find(selected, selectedItem => selectedItem.id == item.id) -> Belt.Option.isNone)
}


@react.component
let make = (
    ~placeholder="Search",
    ~emptySelectionMessage="No items selected",
    ~allItemsSelectedMessage="All items selected",
    ~selected,
    ~inputName,
    ~allItems,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selected: selected,
      searchInput: "",
    },
  )
  <div>

    {
      state.selected->Js.Array2.mapi((item, index) => {
        <input key={string_of_int(index)} type_="hidden" name=inputName value=item.id />
      })->React.array
    }

    <Multiselect
      placeholder
      emptySelectionMessage
      allItemsSelectedMessage
      selected=state.selected
      unselected=unselectedItems(allItems, state.selected)
      onChange={value => send(UpdateSearchInput(value))}
      value=state.searchInput
      onSelect={s => send(SelectItem(s))}
      onDeselect={s => send(DeSelectItem(s))}
    />
  </div>
}

let decodeItem = json => {
  open Json.Decode

  {
    id: field("id", string, json),
    name: field("name", string, json),
  }
}

let makeFromJson = json => {
  open Json.Decode

  make({
    "allItemsSelectedMessage": optional(field("allItemsSelectedMessage", string), json),
    "emptySelectionMessage": optional(field("emptySelectionMessage", string), json),
    "placeholder": optional(field("placeholder", string), json),
    "selected": field("selected", array(decodeItem), json),
    "allItems": field("allItems", array(decodeItem), json),
    "inputName": field("inputName", string, json),
  })
}
