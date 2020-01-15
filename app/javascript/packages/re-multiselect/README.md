# `@pupilfirst/multiselect`

multiselect dropdown component for reason react projects

## Demo

[re-multiselect.pupilfirst.com/](http://re-multiselect.pupilfirst.com/)

## Examples

[Usage in Pupilfirst]()

[Demo]()

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

### `ReMultiSelect` module

`ReMultiselect` is a functor that accepts an Identifer with `type t`.

```reason
module Identifier = {
  type t;
};

// Alias ReMultiselect with an Identifier

module ReMultiselect = ReMultiselect.Make(Identifier);
```

`type t` be of any type that reason supports, ex string, int, variant, etc.

example:

```reason
  module Identifier = {
    type t = City | State | Country
  };
```

### `ReMultiSelect.Selectable` type

ReMultiselect accepts a type `ReMultiselect.Selectable.t`

`t.label`: label for item, example: `some("Country")` (optional)

`t.item`: the item you want to be searched for: `"USA"`

`t.color`: default is gray. You can choose any color from tailwind. example: `"green"` (optional)

`t.searchString`: The string you want to compare against. example `"Country USA United States of America"` note:`"USA"` show up even if the user searches for `"United stated of America"` or `"Country"` (optional)

`t.identifier`: its your type t. example `Country`

You can make a `ReMultiselect.Selectable.t` using make function

example

```reason
ReMultiselect.Selectable.make(
  ~label="Country",
  ~item="USA",
  ~color="green",
  ~searchString="Country USA United States of America",
  ~identifier=Country,
  (),
);
```

### `ReMultiSelect` component

`ReMultiSelect` component accepts

`id`: `string` (optional - should be uniq if you are using multiple)

`placeholder`: `string` (optional)

`value`: `string`

`labelSuffix`: `string` (optional)

`unselected`: `array(`ReMultiselect.Selectable.t)`

`selected`: `array(ReMultiselect.Selectable.t)`

`onChange`: `string => unit` (onChange for value)

`updateSelectionCB`: `ReMultiselect.Selectable.t => unit` (onClick on selection)

`clearSelectionCB`: `ReMultiselect.Selectable.t => unit` (onClick on clear)

example: Check examples folder
