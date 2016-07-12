### 12 July, 2016

#### Features

  - New applicants can now redo their application form as long as they haven't completed the payment step.

#### Content

  - Added a [tour](/tour) of SV.CO's programme.

### 4 July, 2016

#### Features, UI, Content

  - Applications for batch 3 are open! We've been working towards this for the last four weeks. We've released a brand new home page featuring graduates from our first batch, new videos and content on the apply page, and a four-stage application process.

### 20 June, 2016

#### UX and UI

  - There's been a slight modification in the faculty connect request process. Due to a recent change in Google Hangouts, the Hangouts URL can only be generated a little while before the meeting takes place. Emails sent to founders and faculty will now have a link to a new page, which will reveal the Hangouts URL when it is available.
  - When founder is logged in, an _Activity_ link is added to the navbar, pointing to the page listing latest activity from startups.

#### Content

  - Added information about host institute change to the transparency page.

### 13 June, 2016

#### UX and UI

  - Check out our new changelog page! B-) We've applied our styleguide here, and we'll slowly roll out this design language across the entire website.

#### Bugfixes

  - Signed-in sessions were not being shared between _[sv.co](https://sv.co)_ and _[www.sv.co](https://www.sv.co)_. We were serving bad cookies, so we've baked a new batch. Everyone has been signed out as a result; sorry about that.
  - Vocalist is now able to define terms that have a _hyphen_ in them.

### 6 June, 2016

#### Features

  - Vocalist responds to `changelog`, and fetches the latest entry from this changelog.
  - Vocalist includes a summary of latest deployed targets in the response to `state of SV` commands.

#### UX and UI

  - Minor tweaks to navigation links.
  - Removed the option to pause and resume flash notifications.

#### Bugfixes

  - Fixed an issue with displaying feedback on timeline events when the feedback body lacked line-breaks.

### 1 June, 2016

#### Features

  - A form has been added to gather feedback from signed-in founders, on all aspects of the program. It's accessible from the profile dropdown menu (top-right).

#### UX and UI

  - The first version of our unified design guideline is ready. We've been working on it for the last few weeks, and we'll slowly roll out updated design elements over the next couple of weeks - starting with the changelog!

#### Bugfixes

  - There was a report of a rendering error (via the new platform feedback feature!) related to the display of founder targets. That's been taken care of.

### 24 May, 2016

#### Features

  - Tracking improved timeline events for those that were marked as needing improvement.

#### UX and UI

  - Vocalist now ignores case when responding to commands.
  - Removed play and pause buttons on notifications.
  - Updated SV.CO's address; we've got new digs in Bengaluru!

### 17 May, 2016

#### Features

  - Vocalist now supplies definitions to common industry terms using the `define TERM` command.

#### Bugfixes

  - The button to download _Rubric_ for targets was broken during an unrelated change. This has been fixed, and tests have been added.

### 9 May, 2016

#### Features

  - _Review tests_ have been added to targets. This allows founders to take part in small survey-type questionnaires after going through slides and / or completing targets.

#### Content

  - Added more information related to SV.CO's mission in the _About_ section.
  - _Ola_ and _GOQii_ have been listed as partners in the _Talent_ section.

#### Bugfixes

  - URLs that point to `/resources/...` now redirect to the new `/library/...` path. This preserves old links.
  - Improved reliability of reminder notifications sent via vocalist to faculty and founders about imminent connect sessions. They had a tendency to get lost in transit.

### 2 May, 2016

#### Features

  - A _Graduation_ page has been created to showcase our graduation efforts & results.
  - Vocalist includes questions asked by founders in the reminder for faculty members about imminent connect session.

#### Performance

  - We've switched our CDN from Cloudfront to Cloudflare to take advantage of [CNAME flattening](https://sv.co/tvyfw). This lets us bypass the CDN on dynamic page requests for considerable speed-up. Also, Cloudflare is way cooler. B-)

#### Visual

  - Minor changes to site's header and footer, re-organizing links, and such.

#### Bugfixes

  - Vocalist no longer includes an empty _Links attached_ postfix when links aren't available on a timeline event notification.
  - After editing a timeline event and submitting changes, the form now clears instead of remaining in _edit mode_.

### 25 April, 2016

#### Features

  - Vocalist now responds to a bunch of commands that makes her fetch basic information about a batch, for use as intro during weekly _town hall_ meetings.
  - Founder registration flow has been reworked. On-boarding a team of founders is much more straight-forward; the team lead is asked to enter startup information right after user registration, and co-founders being automatically linked once that's done.

### 18 April, 2016

#### Features

  - Vocalist now responds to `targets?` command, responding with list of targets. She can also supply more information with `targets info [NUMBER]`

#### Performance

  - Sped up first load of the website by tweaking a setting on the visit logging library.

#### Bugfixes

  - Blank entries were being shown on Startups page's filter (Google Chrome, on Windows).
  - Vocalist will correctly notify everyone of multiple targets being deployed together to a batch.
  - Founders can no longer register with phone numbers already linked to others.
