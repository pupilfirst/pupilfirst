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

Order alphabetically where possible.

Third-party library translations are at the end of this file, and they follow their own format.

Make sure you include links to documentation related to such third-party translations for when
we (undoubtedly) forget what the strings were for.
