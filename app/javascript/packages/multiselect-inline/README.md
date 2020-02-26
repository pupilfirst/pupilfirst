# `@pupilfirst/multiselect-inline`

A multi-select inline component with search for ReasonReact projects.

## Demo

[multiselect-inline.pupilfirst.com](http://multiselect-inline.pupilfirst.com/)

## Installation

```
npm install @pupilfirst/multiselect-inline
```

Then add `@pupilfirst/multiselect-inline` to bs-dependencies in your bsconfig.json. A minimal example:

```json
{
  "name": "your project",
  "sources": "src",
  "bs-dependencies": ["@pupilfirst/multiselect-inline"]
}
```

## Example

Here's an example interface, to select few sports.

```reason
   module Selectable = {
    type t =
      | Sport(name)
    and name = string;

    let value = t =>
      switch (t) {
      | Sport(name) => name
      };

    let searchString = value;

    let makeSport = name => Sport(name);
  };

  module MultiSelect = MultiselectInline.Make(Selectable);

  type state = {
    searchInput: string,
    selected: array(Selectable.t),
  };

  let unselected = selected => {
    let searchCollection =
      [|
        "Badminton",
        "Tennis",
        "Baseball",
        "Swimming",
        "Volleyball",
        "Football",
        "Formula 1",
        "Squash",
        "Boxing",
      |]
      |> Array.map(sportName => Selectable.makeSport(sportName));
    searchCollection
    |> Js.Array.filter(sport => !(selected |> Array.mem(sport)));
  };

  let setSportSearch = (setState, value) => {
    setState(state => {...state, searchInput: value});
  };

  let select = (setState, state, sport) => {
    let selected = state.selected |> Js.Array.concat([|sport|]);
    setState(_state => {searchInput: "", selected});
  };

  let deSelect = (setState, state, sport) => {
    let selected =
      state.selected
      |> Js.Array.filter(selected =>
           Selectable.value(sport) != Selectable.value(selected)
         );
    setState(_state => {searchInput: "", selected});
  };

  [@react.component]
  let make = () => {
    let (state, setState) =
      React.useState(() => {searchInput: "", selected: [||]});
    <div className="mt-4">
      <h2 className="text-xl font-semibold"> {"Example" |> str} </h2>
      <div className="mt-4">
        <label
          className="block text-xs font-semibold"
          htmlFor="MultiselectInline__search-input-example">
          {"Select your sports:" |> str}
        </label>
      </div>
      <MultiSelect
        placeholder="Search sport"
        emptySelectionMessage="No sport selected"
        selected={state.selected}
        unselected={unselected(state.selected)}
        onChange={setSportSearch(setState)}
        value={state.searchInput}
        onSelect={select(setState, state)}
        onDeselect={deSelect(setState, state)}
      />
    </div>;
  };

```

See this code in action here: https://multiselect-inline.pupilfirst.com

### Other examples

- [Real world Usage in Pupilfirst](https://github.com/SVdotCO/pupilfirst/blob/master/app/javascript/schools/courses/components/curriculum_editor/CurriculumEditor__TargetDetailsEditor.re)

## Usage

`MultiselectInline.Make` is a functor that accepts a module with with `type t` that has functions `value` and `searchString`.

| Function       | Type     | Description                                                                                                                                                                           |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `value`        | `string` | The name, or title of a item.                                                                                                                                                         |
| `searchString` | `string` | The string you want to compare the user's input against. For example, if the `searchString` for an item is `"Formula 1"`, it will show up if the user searches for `"Form"` or `"1"`. |

### `MultiselectInline` component

`MultiselectInline` is a Reason-React component that accepts an array of unselected and selected items, both of which have to be of the type `MultiselectInline.Selectable.t`.

The `MultiselectInline` component accepts the following props:

| Prop                      | Type                                     | Description                                                                                                         |
| ------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `id`                      | `string` (optional)                      | `id` of the input element; you can use this set unique id to the input text field.                                  |
| `placeholder`             | `string` (optional)                      | Placeholder for the input search field.                                                                             |
| `value`                   | `string`                                 | Value of input element; this is a controlled component - you hold the state.                                        |
| `onChange`                | `string => unit`                         | `onChange` to set value of the input in state.                                                                      |
| `unselected`              | `array(MultiselectInline.Selectable.t)`  | The array of unselected options.                                                                                    |
| `selected`                | `array(MultiselectInline.Selectable.t)`  | The array of selected options.                                                                                      |
| `onSelect`                | `MultiselectInline.Selectable.t => unit` | Callback for when an item is selected.                                                                              |
| `onDeselect`              | `MultiselectInline.Selectable.t => unit` | Callback for when an item is removed.                                                                               |
| `emptySelectionMessage`   | `string` (optional)                      | Empty message shown when the there are no selected items. Defaults to `No items selected`.                          |
| `allItemsSelectedMessage` | `string` (optional)                      | This message is shown when all the items are selected from the dropdown. Defaults to 'You have selected all items!' |
| `colorForSelected`        | `string` (optional)                      | This is the color used to indicate selected items. The default is orange.                                           |
