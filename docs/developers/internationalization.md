---
id: internationalization
title: Internationalization
sidebar_label: Internationalization
---

Pupilfirst LMS uses _Rails Internationalization_ (I18n) API for internationalization and localization.

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

You can use the [YAML Sort Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=PascalReitermann93.vscode-yaml-sort)
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
