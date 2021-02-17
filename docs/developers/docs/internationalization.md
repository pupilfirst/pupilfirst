---
id: internationalization
title: Internationalization
sidebar_label: Internationalization
---

Pupilfirst LMS uses _Rails Internationalization_ (I18n) API for internationalization and localization.


## Organization of en.yml
- `components.COMPONENT.*` - component-specific strings
- `jobs.[MODULE].JOB.*` - strings used by jobs
- `models.MODEL.COLUMN.*` = translation of database values to display values
- `mutations.MUTATION.*` = strings used by mutations
- `queries.QUERY.*` = strings used by resolvers and mutators
- `shared.*` - shared strings
- `CONTROLLER.ACTION.*` = display_value

CONTROLLER is always the plural version. For example: `FoundersController#edit = founders.edit.*`

Always order keys alphabetically.

Third-party library translations are at the end of this file, and they follow their own format.

Make sure you include links to documentation related to such third-party translations in `docs/developers/docs/internationalization.md` for when
we (undoubtedly) forget what the strings were for.

## VSCode plugin (Works only with .res files)

You can use [pupilfirst-translator VSCode plugin](https://marketplace.visualstudio.com/items?itemName=bodhi.pupilfirst-translator) to set keys in I18n Yaml file.

### Usage
1. Select a string that needs to be added to `en.yml` file
2. Right click and select _Pupilfirst Transilate_ button (You could also use `ctrl + shift + t` keybaord shortcut)
3. Enter the key (example: `video.description_label`)
4. Click `enter`

This will create an entry for the `key` you have added in `en.yml` file and replaces the selection.


## THIRD-PARTY LIBRARY TRANSLATIONS
- `content_type_invalid` and `limit_out_of_range` are custom error messages for the active_storage_validations gem.
