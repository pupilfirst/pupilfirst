---
id: internationalization
title: Internationalization
sidebar_label: Internationalization
---

Pupilfirst LMS uses _Rails Internationalization_ (I18n) API for internationalization and localization.

## Adding a new language

Let's imagine that you're trying to add translations for a language with the ISO 639 code `lang`. These are the steps you'd have to take:

### Create the language's YML file

Create a file at the location `config/locales/lang.yml`. Follow [Rails-conventions for authoring a translation file](https://guides.rubyonrails.org/i18n.html#providing-translations-for-internationalized-strings). Also go through the section below on how we've organized the contents of the `en.yml` file.

### Make translations accessible to front-end code

Load the new language's translations in front-end code by editing `app/frontend/shared/i18n.js` and adding:

```js
// ...other language imports
import trLang from "../locales/lang.json";

const i18n = new I18n();

// ...other language stores
i18n.store(trLang);
```

This will make relevant language strings accessible to client-side code.

### Making the new language available to users

Add `lang` to the comma-separated list in the environment variavble `I18N_AVAILABLE_LOCALES`. This will add `lang` to the list of languages available for selection via users' _Profile Edit_ page.

### Setting the new language as default

If you'd like to set the language you're adding as the default for your deployment of the LMS, set the `I18N_DEFAULT_LOCALE` environment variable to `lang`.

## Organization of en.yml

| Key                         |                       Value                       |
| --------------------------- | :-----------------------------------------------: |
| `components.COMPONENT.*`    |            Component-specific strings.            |
| `jobs.MODULE.CLASS.*`       |               Strings used by jobs.               |
| `layouts.PATH`              |             Strings used in layouts.              |
| `mailers.CLASS.ACTION.*`    |             Strings used in mailers.              |
| `models.MODEL.COLUMN.*`     | Translation of database values to display values. |
| `mutations.MUTATION.*`      |            Strings used by mutations.             |
| `presenters.MODULE.CLASS.*` |            Presenter-specific strings.            |
| `queries.QUERY.*`           |      Strings used by resolvers and mutators.      |
| `services.MODULE.CLASS.*`   |             Strings used by services.             |
| `shared.*`                  |                  Shared strings.                  |
| `CONTROLLER.ACTION.*`       |             Request-based responses.              |
| `MODULE.CLASS.*`            |           Strings used by library code.           |

- `CONTROLLER` is always the plural version. For example: `StudentsController#edit` is keyed as `students.edit.*`
- Always order keys alphabetically. Use [the YAML Sort Visual Studio Code extension](#yaml-sort), to manage this.
- Third-party library translations follow their own format, and any customization of those should be [documented
  _here_ in this file](#third-party-library-translations).

## YAML Sort

You should use the [YAML Sort Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=PascalReitermann93.vscode-yaml-sort)
to validate and sort the contents of `LANG.yml` files.

Use the following configuration when using this extension:

```json
{
  "vscode-yaml-sort.quotingType": "\"",
  "vscode-yaml-sort.useLeadingDashes": false
}
```

## Third-party library translations

- `errors.messages.content_type_invalid` and `errors.messages.limit_out_of_range` are custom error messages for
  the [active_storage_validations](https://github.com/igorkasyanchuk/active_storage_validations#internationalization-i18n) gem.
