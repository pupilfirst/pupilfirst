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

## Usage

## Examples

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

### Other examples

[Real world Usage in Pupilfirst]()

[Code for Multiselect Demo]()

## Documentation

`ReMultiselect.Make` is a functor that accepts a module with with `type t`. This enables you to pass through any kind of data that identifies each selectable item in your application.

#### `ReMultiselect` component

`ReMultiselect` is a Reason-React component that accepts an array of unselected and selected items both of which have to be of the type `ReMultiSelect.Selectable.t`

`ReMultiselect` component accepts:

- `id`: `string` (optional - should be uniq if you are using multiple)

- `placeholder`: `string` (optional)

- `value`: `string`

- `labelSuffix`: `string` (optional)

- `unselected`: `array(ReMultiselect.Selectable.t)`

- `selected`: `array(ReMultiselect.Selectable.t)`

- `onChange`: `string => unit` (onChange for value)

- `updateSelectionCB`: `ReMultiselect.Selectable.t => unit` (onClick on selection)

- `clearSelectionCB`: `ReMultiselect.Selectable.t => unit` (onClick on clear)

#### `ReMultiselect.Selectable` type

`ReMultiselect` accepts a type `ReMultiselect.Selectable.t`

- `t.label`: label for item, example: `some("Country")` (optional)

- `t.item`: the item you want to be searched for: `"USA"`

- `t.color`: default is gray. You can choose any color from tailwind. example: `"green"` (optional)

- `t.searchString`: The string you want to compare against. example `"Country USA United States of America"` note:`"USA"` show up even if the user searches for `"United stated of America"` or `"Country"` (optional)

- `t.identifier`: its your type t.

Detailed example: Check examples folder
