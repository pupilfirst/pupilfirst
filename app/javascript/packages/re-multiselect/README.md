# `@pupilfirst/multiselect`

Multiselect dropdown component for reason react projects

## Demo

[multiselect.pupilfirst.com](http://re-multiselect.pupilfirst.com/)

## Installation

```
npm install @pupilfirst/multiselect
```

Then add `@pupilfirst/multiselect` to bs-dependencies in your bsconfig.json. A minimal example:

```json
{
  "name": "your project",
  "sources": "src",
  "bs-dependencies": ["@pupilfirst/multiselect"]
}
```

## Minimal Example

```reason
module Identifier = {
  type t =
    | City(index)
    | Country(index)
  and index = int;
};

// create a Multiselect
module Multiselect = ReMultiselect.Make(Identifier);

type state = {
  selected: array(Multiselect.Selectable.t),
  searchString: string,
};

let unselected =
  [|"Delhi", "Beijing", "Washington D.C"|]
  |> Array.mapi((index, city) =>
        Multiselect.Selectable.make(~item=city, ~identifier=City(index), ())
      );

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

`ReMultiselect.Make` is a functor that accepts a module with with `type t`. This enables you to pass through any kind of data that identifies each selectable item in your application.

### `ReMultiselect` component

`ReMultiselect` is a Reason-React component that accepts an array of unselected and selected items, both of which have to be of the type `ReMultiSelect.Selectable.t`.

The `ReMultiselect` component accepts:

- `id`: `string` (optional) - `id` of the input element; you can use this to label the input.

- `placeholder`: `string` (optional) - placeholder for the input element.

- `value`: `string` - value of input element; this is
a controlled component - you hold the state.

- `onChange`: `string => unit` - `onChange` for the input element.

- `unselected`: `array(ReMultiselect.Selectable.t)` - the array of unselected options.

- `selected`: `array(ReMultiselect.Selectable.t)` - the array of selected options.

- `selectCB`: `ReMultiselect.Selectable.t => unit` - callback for when a item is selected.

- `deselectCB`: `ReMultiselect.Selectable.t => unit` - callback for when an item is removed.

- `labelSuffix`: `string` (optional) - defaults to `:` - this is the separator between the _selectable's_ `label` and `title`.

### `ReMultiselect.Selectable` type

`ReMultiselect` operated using a type `ReMultiselect.Selectable.t`. You'll need to work with in in the `selected`, `unselected`, `selectCB` and `deselectCB` props.

These can be created by calling the `ReMultiselect.Selectable.make` function. For example:

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

- `t.label`: `option(string)` - label for a selectable item.

- `t.value`: `string` - the name, or title of a item.

- `t.searchString`: `option(string)` - the string you want to compare the user's input against. For example, if the `searchString` for an item is `"Country USA United States of America"`, it will show up if the user searches for `"United stated of America"` or `"Country"`, or `USA`. If left out, the `searchString` will default to `value`.

- `t.color`: `option(string)` - defaults to `gray`. You can choose any color from your Tailwind config.

- `t.identifier`: `Identifier.t` - This is your internal data type; this value will be passed in calls to `selectCB` and `deselectCB`, and can be used to identify an item in your data store.
