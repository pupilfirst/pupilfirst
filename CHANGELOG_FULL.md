## Ongoing

- New Founder dashboard design is being implemented. [[Trello]](https://trello.com/c/sITTzECe)
- Backend for new dashboard is being worked on. [[Trello]](https://trello.com/c/5tbjVflT)
- New timeline builder for the new dashboard is being wired up with React. [[Trello]](https://trello.com/c/EvCvyGdH)

## 2016.12.19

- Deployed a new target overview page for revamped program framework. [[Trello]](https://trello.com/c/rPvTRmUT)
- Add a link to view uploaded partnership deed from the stage 4 submission page on active admin. [[Trello]](https://trello.com/c/oW8EqOUU)
- Added a fallback identicon logo for startups, colored according to their auto-generated name. [[Trello]](https://trello.com/c/ihrvZlEZ)
- Automatically select 11:59 PM as time for `ends_at` of a batch's applications stage. [[Trello]](https://trello.com/c/iVD2ztcN)
- Updated address given on the apply page. [[Trello]](https://trello.com/c/fsifLdjl)
- Added some additional validations to Target. [[Trello]](https://trello.com/c/wRtX41Hl)
- Improved how `sequence`-s were used in Factory Girl templates. [[Trello]](https://trello.com/c/fxl9mEAC)
- Added Rails-specific checks to our Rubocop runs. [[Trello]](https://trello.com/c/UkWirRRS)

## 2016.12.12

- Individual users can now be logged out (when they visit the website) from the admin interface using a new _Sign Out At Next Request_ feature on the User page. [[Trello]](https://trello.com/c/qoUXik8V)
- Fixed broken Founder's team member add / edit form. Incorrely applied HTML5 validations were blocking the form from being submitted. [[Trello]](https://trello.com/c/QaiLMzaC)
- The OAuth login method now correctly redirects user to referer path after successful login. [[Trello]](https://trello.com/c/FZTXZICE)
- A signed-in user, registering for MOOC is now taken directly to start page of MOOC, instead of being emailed another login link. [[Trello]](https://trello.com/c/OrtU2aRM)
- The admin interface for creating application submissions now allows for searching of batch application using select2. [[Trello]](https://trello.com/c/y3fTfvmT)
- Removed use of `member_label` option from all Formtastic forms since it has been deprecated. [[Trello]](https://trello.com/c/xQWbKUp6)
- Removed `invited_batch` association from `Founder`. [[Trello]](https://trello.com/c/KSTtTMs5)
- `TargetGroup.number` was renamed to `sort_index` to clarify its purpose. [[Trello]](https://trello.com/c/4yoHu0bz)
- Removed unused `full_validation` accessor from Startup and Founder. [[Trello]](https://trello.com/c/JS9HE4ac)

## 2016.12.05

- Changes to database and admin interface to account for Founder Dashboard and Targets Framework is mostly complete. [[Trello]](https://trello.com/c/1Q0bNMcR)
- Removed the ability for founders to add new founders and remove existing founders from their startup. [[Trello]](https://trello.com/c/Rggpxzqf)
- Founders no longer have to validate their phone numbers - it is freely editable. [[Trello]](https://trello.com/c/A1mM8nP2)
- Password change form was removed from Founder's edit page. [[Trello]](https://trello.com/c/0EG9eMXd)
- Founder edit form has been improved to display filename of existing identification proof. [[Trello]](https://trello.com/c/UDt744bi)
- Incorrect office address on the `/about/contact` page has been updated. [[Trello]](https://trello.com/c/lWlNp20a)
- MOOC Students list on admin interface has been updated to include module completion scopes. [[Trello]](https://trello.com/c/lw1XCmhk)
- Generated partnership deed has been updated to list the team lead as the first in any list. [[Trello]](https://trello.com/c/ceBNV7Ob)
- Content was added to the Stage 5 (completion) page of application process. [[Trello]](https://trello.com/c/i8ZS7KSE)
- Applicant's ID and Address proof are now displayed in the admin interface. [[Trello]](https://trello.com/c/oMKQ8fev)
- Stage 4 forms now display an _Uploading..._ message when the button is disabled after clicking submit. [[Trello]](https://trello.com/c/zZMogPOP)
- Removed unused code related to removal of a startup via user-initiated action. [[Trello]](https://trello.com/c/IkJl3B3g)
- Removed unused `test_background` action from `HomeController`, along with related files. [[Trello]](https://trello.com/c/47enFle3)
- Seeded data for Founders has been updated to match data available at the end of current admission process. [[Trello]](https://trello.com/c/WbFzcOaw)

## 2016.11.29

- Onboaring flow for applicants who have completed the application is online. Trello [[1]](https://trello.com/c/DwPEHw4E) [[2]](https://trello.com/c/OldpCMgw)
- Application fee refund is now applied to another applicant if team lead has scholarship. [[Trello]](https://trello.com/c/1B9R2566)
- `target_templates` table has been removed in favor of using the `targets` table. [[Trello]](https://trello.com/c/bcSLW4JN)
- Fix: Intercom image uploads were broken. [[Trello]](https://trello.com/c/Rr6lDSUo)
- Visual timeline of _CareerKhojj_ was updated. [[Trello]](https://trello.com/c/qH1vLXB4)
- Stage 4 completion pages have a new banner. [[Trello]](https://trello.com/c/4S2tDdf6)
- Seed final stage application and applicants. [[Trello]](https://trello.com/c/ADnDQxrg)
- Admissions Stats notification job now has a basic spec. [[Trello]](https://trello.com/c/verll8rm)
- `BatchApplication#status` now correctly handles _closed_ state applications. [[Trello]](https://trello.com/c/ldDeR6Rz)
- Startups are now created with a _fun name_. [[Trello]](https://trello.com/c/xdmQNNYS)
- Founders do not require registration scopes. [[Trello]](https://trello.com/c/7Bv91hhr)
- Upgrade to Ruby 2.3.3. [[Trello]](https://trello.com/c/5yat3uvI)
- Founder's `first_name` and `last_name` have been merged to new `name`. [[Trello]](https://trello.com/c/yh0Mkfir)
- Content has been added for final stage rejection and expiry pages. [[Trello]](https://trello.com/c/WDJdFd93)

## 2016.11.21

- Admissions page (Stage 4) with forms and dynamic agreement PDF generation has been deployed. [[Trello]](https://trello.com/c/mdaZ6Avq)
- Keynote version of Program Framework is ready. [[Trello]](https://trello.com/c/RGTgUj2U)
- Visual timeline created for CareerKhoj has been added to the MOOC. [[Trello]](https://trello.com/c/DcBksRuo)
- Pre-selection stage flow has been spec-d. Trello [[1]](https://trello.com/c/FfONzln4) [[2]](https://trello.com/c/iufkq6vS)
- Updated filters, removing a broken one from admin interface MOOC students list. [[Trello]](https://trello.com/c/wYw07wxp)
- Project's Ruby has been upgraded to latest 2.3.2. [[Trello]](https://trello.com/c/K2INl9nr)
- Admin interface's Payments listing page has been sped up with N+1 optimization. [[Trello]](https://trello.com/c/mShLs3ZS)
- A bug preventing cofounder addition for swept applications has been squashed. [[Trello]](https://trello.com/c/Kc28MtAp)
- Have switching error monitoring solution from Sentry to Rollbar. [[Trello]](https://trello.com/c/ltZ5Y0Nb)
- Fixed incorrect stat reported by daily admissions stats notifier. [[Trello]](https://trello.com/c/yOZLvkd8)

## 2016.11.14

- Founder login with password has been removed in favor of logging in with OAuth2, or via manual email verification. This unifies login action with MOOC Student's login. Trello [[1]](https://trello.com/c/IEf8UeN8) [[2]](https://trello.com/c/x66SgwzX)
- Added _Microsoft Student Partner_ as reference option on the application form, and replaced reference value for existing _MSP_ applicants. Trello [[1]](https://trello.com/c/hpKY4mAN) [[2]](https://trello.com/c/DF2ymoYd)
- Fixed an issue with rendering list of startup team members in admin interface. Also fixed an crash related to displaying team member information when no avatar was set. [[Trello]](https://trello.com/c/ENZw6nQN)
- Fixed a crash related to manual move of applications from stage 1 to 2, by assigning a default application team size of 2. [[Trello]](https://trello.com/c/1N9LyZEv)
- Fixed namespacing of a few service classes, after policy regarding their naming was updated. [[Trello]](https://trello.com/c/b6QBu9pz)
- Fixed a crash on library page which happened when non-numbers were passed to the `page` parameter. [[Trello]](https://trello.com/c/nnYiThxk)
- Removed unused / old files from `/public`. [[Trello]](https://trello.com/c/OMWtAIQe)

## 2016.11.7

- Added content and illustrations for Module 3 of SixWays MOOC. [[Trello]](https://trello.com/c/rqodMUFn)
- Updated Batch 4 interview dates on /apply. [[Trello]](https://trello.com/c/njy0gqQE)
- Updated information about cutoff percentile and interview dates for Stage 3 of Batch 4. [[Trello]](https://trello.com/c/g9S0sbCf)
- Removed GTU launch page and redirected link from GTU landing page to SixWays registration page. [[Trello]](https://trello.com/c/ai6Eo6c1)
- All error pages now use Bootstrap 4 layout. [[Trello]](https://trello.com/c/U5D2s3bh)
- Refactored `InstamojoController` to avoid deprecation warnings [[Trello]](https://trello.com/c/MsEXOab8)
- Fixed issues with Select2 selectors on Batch application form and Library tag filter form when navigating away from, and returning back to the page. [[Trello]](https://trello.com/c/H3W2vGvt)
- Added some basic statistics about the SixWays MOOC to admin dashboard. [[Trello]](https://trello.com/c/priF7ed2)
- Added information specific to _Microsoft Student Partners_ to apply page. [[Trello]](https://trello.com/c/B9I0hN1t)
- _Devise_ library is now used to authenticate and manage user sessions (only MOOC students for now). [[Trello]](https://trello.com/c/0Sg7XDAD)
- Fix: Admin interface button to load latest Intercom conversations was broken. [[Trello]](https://trello.com/c/o7FwDiLD)
- Fix: View link to Faculty on admin interface was broken. [[Trello]](https://trello.com/c/fL7CSRQ2)
- Lots of little optimizations related to recent upgrade to Rails 5. Trello [[1]](https://trello.com/c/dzniSrm5) [[2]](https://trello.com/c/CVFGwaQ4)
- Fix: Admin interface to edit batch applications were unable to link applicants. [[Trello]](https://trello.com/c/E6NXuItq)
- Fix: Admin interface to create and edit batch applications was loading extremely slowly due to N+1 query issues. [[Trello]](https://trello.com/c/e50wFdhb)
- Added anchor links to fee and FAQ sections on apply page. [[Trello]](https://trello.com/c/xgZK5D30)
- Added co-founder email IDs to admin interface's Batch applicant export feature. [[Trello]](https://trello.com/c/GyK2Esrg)
