## Ongoing

- Review of visual timeline created for CareerKhoj is pending. [[Trello]](https://trello.com/c/DcBksRuo)
- Addition of specs for pre-selection stage flow is pending. [[Trello]](https://trello.com/c/leh3joia)
- Review of keynote version of Program Framework is pending. [[Trello]](https://trello.com/c/RGTgUj2U)
- Admissions page (Stage 4) with forms and dynamic agreement PDF generation is being built. [[Trello]](https://trello.com/c/mdaZ6Avq)
- Enterprise Edition prototype is under construction. Trello [[1]](https://trello.com/c/2sNiJrbc) [[2]](https://trello.com/c/0MZB3vhU)

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
