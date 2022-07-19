# `@pupilfirst/pf-icon`

Collection of custom icons created by [pupilfirst lms](https://www.pupilfirst.com/)

## Demo

[icons.pupilfirst.com](http://icons.pupilfirst.com/)

## Installation

```
npm install @pupilfirst/pf-icon
```

Then add `@pupilfirst/pf-icon` to bs-dependencies in your bsconfig.json. A minimal example:

```json
{
  "name": "your project",
  "sources": "src",
  "bs-dependencies": ["@pupilfirst/pf-icon"]
}
```

## Example

```reason
<PfIcon className="if i-eye-solid" />
```

List of icons : [icons.pupilfirst.com](http://icons.pupilfirst.com/)

## Usage - Reason React

### `PfIcon` component

| Prop        | Type     | Description             |
| ----------- | -------- | ----------------------- |
| `className` | `string` | Class name for the icon |

Refer to [icons.pupilfirst.com](http://icons.pupilfirst.com/) for full list of icons and and its usages

## Usage - Non React

Import the `pf-icon` listener that converts the `<i>` tags to `<svg>`

```js
import { addListener } from "@pupilfirst/pf-icon";

addListener();
```

You can add an icon easily by adding the `pf-icon` class on an `<i>` tag.

Example

```html
<i class="if i-plus-circle-regular"></i>
```
