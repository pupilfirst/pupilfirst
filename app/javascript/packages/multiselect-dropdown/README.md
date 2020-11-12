# `@pupilfirst/multiselect-dropdown`

A multi-select dropdown component for ReasonReact projects.

## Demo

[multiselect-dropdown.pupilfirst.com](http://multiselect-dropdown.pupilfirst.com/)

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
  module Selectable = {
    type t =
      | City(pincode, name)
      | Country(countryCode, name)
    and pincode = string
    and countryCode = string
    and name = string;

    let label = _t => None;

    let value = t =>
      switch (t) {
      | City(_pincode, name) => name
      | Country(_countryCode, name) => name
      };

    let searchString = t => t |> value;
    let color = _t => "gray";

    let makeCountry = (~name, ~countryCode) => Country(countryCode, name);
    let makeCity = (~name, ~pincode) => City(pincode, name);
  };

  // create a Multiselect
  module Multiselect = MultiselectDropdown.Make(Selectable);

  type state = {
    selected: array(Selectable.t),
    searchString: string,
  };

  let unselected = [|
    Selectable.makeCity(~name="Delhi", ~pincode=""),
    Selectable.makeCountry(~name="India", ~countryCode="91"),
    Selectable.makeCity(~name="Washington D.C", ~pincode=""),
    Selectable.makeCountry(~name="USA", ~countryCode="1"),
  |];

[@react.component]
let make = () => {
  let (state, setState) =
    React.useState(() => {searchString: "", selected: [||]});
  <Multiselect
    unselected
    selected={state.selected}
    onSelect={selectable =>
      setState(s =>
        {
          searchString: "",
          selected: s.selected |> Array.append([|selectable|]),
        }
      )
    }
    onDeselect={_ => ()}
    value={state.searchString}
    onChange={searchString => setState(s => {...s, searchString})}
  />;
};

```

See this code, and a more advanced version, in action here: https://multiselect-dropdown.pupilfirst.com

### Other examples

- [Real world Usage in Pupilfirst](https://github.com/SVdotCO/pupilfirst/tree/master/app/javascript/schools/courses/components/students_editor/StudentsEditor__Search.re)

## Usage

`MultiselectDropdown.Make` is a functor that accepts a module with with `type t` that has functions `label`, `value`, `searchString`, and `color`

| Function       | Type             | Description                                                                                                                                                                                                                                                                                                   |
| -------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `label`        | `option(string)` | Label for a selectable item.                                                                                                                                                                                                                                                                                  |
| `value`        | `string`         | The name, or title of a item.                                                                                                                                                                                                                                                                                 |
| `searchString` | `option(string)` | The string you want to compare the user's input against. For example, if the `searchString` for an item is `"Country USA United States of America"`, it will show up if the user searches for `"United stated of America"` or `"Country"`, or `USA`. If left out, the `searchString` will default to `value`. |
| `color`        | `option(string)` | Defaults to `gray`. You can choose any color from your Tailwind config.                                                                                                                                                                                                                                       |

### `MultiselectDropdown` component

`MultiselectDropdown` is a Reason-React component that accepts an array of unselected and selected items, both of which have to be of the type `MultiselectDropdown.Selectable.t`.

The `MultiselectDropdown` component accepts the following props:

| Prop             | Type                                       | Description                                                                            |
| ---------------- | ------------------------------------------ | -------------------------------------------------------------------------------------- |
| `id`             | `string` (optional)                        | `id` of the input element; you can use this to label the input.                        |
| `placeholder`    | `string` (optional)                        | Placeholder for the input element.                                                     |
| `value`          | `string`                                   | Value of input element; this is a controlled component - you hold the state.           |
| `onChange`       | `string => unit`                           | `onChange` for the input element.                                                      |
| `unselected`     | `array(MultiselectDropdown.Selectable.t)`  | The array of unselected options.                                                       |
| `selected`       | `array(MultiselectDropdown.Selectable.t)`  | The array of selected options.                                                         |
| `onSelect`       | `MultiselectDropdown.Selectable.t => unit` | Callback for when an item is selected.                                                 |
| `onDeselect`     | `MultiselectDropdown.Selectable.t => unit` | Callback for when an item is removed.                                                  |
| `labelSuffix`    | `string` (optional)                        | This is the separator between the _selectable's_ `label` and `title`. Defaults to `:`. |
| `emptyMessage`   | `string` (optional)                        | Empty message shown when the search result is empty. Defaults to `No results found`.   |
| `hint`           | `string` (optional)                        | Message shown on click when value is empty.                                            |
| `defaultOptions` | `array(MultiselectDropdown.Selectable.t)`  | The array of default options that will show on click when `value` is empty             |
