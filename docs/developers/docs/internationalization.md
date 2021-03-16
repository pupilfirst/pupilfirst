---
id: internationalization
title: Internationalization
sidebar_label: Internationalization
---

Pupilfirst LMS uses _Rails Internationalization_ (I18n) API for internationalization and localization.

## Organization of en.yml

| Key                      |                       Value                       |
| ------------------------ | :-----------------------------------------------: |
| `components.COMPONENT.*` |            Component-specific strings.            |
| `jobs.[MODULE].JOB.*`    |               Strings used by jobs.               |
| `models.MODEL.COLUMN.*`  | Translation of database values to display values. |
| `mutations.MUTATION.*`   |            Strings used by mutations.             |
| `queries.QUERY.*`        |      Strings used by resolvers and mutators.      |
| `shared.*`               |                  Shared strings.                  |
| `CONTROLLER.ACTION.*`    |        Strings used in traditional views.         |

- `CONTROLLER` is always the plural version. For example: `FoundersController#edit` is keyed as `founders.edit.*`
- Always order keys alphabetically. If you use [the VSCode plugin](#visual-studio-code-plugin), this will be done automatically.
- Third-party library translations follow their own format, and any customization of those should be [documented
  _here_ in this file](#third-party-library-translations).

## Visual Studio Code plugin

**Important Note:** This plugin only works within ReScript (`.res`) files at the moment.

You can use the [pupilfirst-translator VSCode plugin](https://marketplace.visualstudio.com/items?itemName=bodhi.pupilfirst-translator)
to quickly move strings from UI components to the I18n YAML file.

### Usage

1. Select a string that needs to be moved to `en.yml`.
2. Right click and select _Pupilfirst Translate_ button. You can also use the `Ctrl+Shift+i` keyboard shortcut.
3. Enter the key. For example: `video.description_label`.
4. Press `Enter` to confirm.

This will create an entry for the `key` you have added in `en.yml` file and replaces the selection.

## Third-party library translations

- `errors.messages.content_type_invalid` and `errors.messages.limit_out_of_range` are custom error messages for
  the [active_storage_validations](https://github.com/igorkasyanchuk/active_storage_validations#internationalization-i18n) gem.
