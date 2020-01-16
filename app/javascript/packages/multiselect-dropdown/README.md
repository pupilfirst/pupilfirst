# `@pupilfirst/multiselect-dropdown`

A multi-select dropdown component for ReasonReact projects.

## Demo

[multiselect.pupilfirst.com](http://re-multiselect.pupilfirst.com/)

## Installation

```
npm install @pupilfirst/multiselect-dropdown
```

Then add `@pupilfirst/multiselect-dropdown` to bs-dependencies in your bsconfig.json. A minimal example:

```json
{
  "name": "your project",
  "sources": "src",
  "bs-dependencies": ["@pupilfirst/multiselect-dropdown"]
}
```

## Minimal Example

```reason
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
  Multiselect.Selectable.make(~item="Washington D.C", ~identifier=City(2), ()),
  Multiselect.Selectable.make(~item="USA", ~identifier=Country(1), ()),
|];

[@react.component]
let make = () => {
  let (state, setState) =
    React.useState(() => {searchString: "", selected: [||]});
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
    clearSelectionCB={_ => ()}
    value={state.searchString}
    onChange={searchString => setState(s => {...s, searchString})}
  />;
};

```

See this code, and a more advanced version, in action here: https://re-multiselect.pupilfirst.com

### Other examples

- [Real world Usage in Pupilfirst]()

## Usage

`MultiselectDropdown.Make` is a functor that accepts a module with with `type t`. This enables you to pass through any kind of data that identifies each selectable item in your application.

### `MultiselectDropdown` component

`MultiselectDropdown` is a Reason-React component that accepts an array of unselected and selected items, both of which have to be of the type `MultiselectDropdown.Selectable.t`.

The `MultiselectDropdown` component accepts the following props:

| Prop          | Type                                       | Description                                                                            |
| ------------- | ------------------------------------------ | -------------------------------------------------------------------------------------- |
| `id`          | `string` (optional)                        | `id` of the input element; you can use this to label the input.                        |
| `placeholder` | `string` (optional)                        | Placeholder for the input element.                                                     |
| `value`       | `string`                                   | Value of input element; this is a controlled component - you hold the state.           |
| `onChange`    | `string => unit`                           | `onChange` for the input element.                                                      |
| `unselected`  | `array(MultiselectDropdown.Selectable.t)`  | The array of unselected options.                                                       |
| `selected`    | `array(MultiselectDropdown.Selectable.t)`  | The array of selected options.                                                         |
| `selectCB`    | `MultiselectDropdown.Selectable.t => unit` | Callback for when an item is selected.                                                 |
| `deselectCB`  | `MultiselectDropdown.Selectable.t => unit` | Callback for when an item is removed.                                                  |
| `labelSuffix` | `string` (optional)                        | This is the separator between the _selectable's_ `label` and `title`. Defaults to `:`. |

### `MultiselectDropdown.Selectable` type

`MultiselectDropdown` operated using a type `MultiselectDropdown.Selectable.t`. You'll need to work with in in the `selected`, `unselected`, `selectCB` and `deselectCB` props.

These can be created by calling the `MultiselectDropdown.Selectable.make` function. For example:

```reason
Multiselect.Selectable.make(
  ~label="Country",
  ~value="USA",
  ~searchString="Country USA United States of America",
  ~color="orange",
  ~identifier=Identifier.Country(1),
  ()
);
```

| Argument       | Type             | Description                                                                                                                                                                                                                                                                                                   |
| -------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `label`        | `option(string)` | Label for a selectable item.                                                                                                                                                                                                                                                                                  |
| `value`        | `string`         | The name, or title of a item.                                                                                                                                                                                                                                                                                 |
| `searchString` | `option(string)` | The string you want to compare the user's input against. For example, if the `searchString` for an item is `"Country USA United States of America"`, it will show up if the user searches for `"United stated of America"` or `"Country"`, or `USA`. If left out, the `searchString` will default to `value`. |
| `color`        | `option(string)` | Defaults to `gray`. You can choose any color from your Tailwind config.                                                                                                                                                                                                                                       |
| `identifier`   | `Identifier.t`   | This is your internal data type; this value will be passed in calls to `selectCB` and `deselectCB`, and can be used to identify an item in your data store.                                                                                                                                                   |
