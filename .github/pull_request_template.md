## Proposed Changes

- Change 1
- Change 2
- More?

@pupilfirst/developers

## Merge Checklist

- [ ] Add specs that demonstrate bug / test a new feature.
- [ ] Check if route, query, or mutation authorization looks correct.
  - Add tests for authorization, if required.
- [ ] Ensure that UI text is kept in I18n files.
- [ ] Update developer and product docs, where applicable.
  - If the documentation updates include images, ensure they are compressed.
- [ ] Prep screenshot or demo video for changelog entry, and attach it to issue.
- [ ] Check if new tables or columns that have been added need to be handled in the following services:
  - `Users::DeleteAccountService`
  - `Courses::CloneService`
  - `Courses::DeleteService`
  - `Courses::DemoContentService`
  - `Levels::CloneService`
  - `Schools::DeleteService`
- [ ] Check if changes in _packaged_ components have been published to `npm`.
- [ ] Add development seeds for new tables.
- [ ] If the updates involve Graph mutations ensure that the files are migrated to the new approach without a mutator.
- [ ] If the updates involve adding a new table ensure that rate limiting is added and documented in the `docs/developers/rate_limiting.md` file.
