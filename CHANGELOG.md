### 3 April, 2017

#### Features

- Founders now receive notifications from Vocalist when they receive karma points.

#### UX and UI

- Added a check to validate length of timeline event description before submitting information from the timeline builder.

#### Content

- The `/activity` page was removed because it had very little activity (ouch) in terms of page-views and was outdated.

#### Bugfixes

- Fixed broken validation for founder's date of birth on profile edit form.
- Fixed an issue with the resume link on founder profile which caused it to point to outdated / incorrect locations.
- Fixed incorrect positioning on _Add Event_ button on the founder dashboard when viewing using mobile devices.
- Fixed broken styling of the contact form on the `/talent` page.

### 27 March, 2017

#### Features

  - The founder dashboard has been rebuilt to better match our program's objectives and for greater ease of use.

#### Performance

  - We've enabled a _Cloudflare_ feature which offers automatic image compression, this should help users with slow internet connections.

#### Bugfixes

  - Fixed a crash on founder profile edit page when uploading non-image files as college identification.

### 20 March, 2017

#### Features

  - Added some new fields to the Founder profile edit page to accept data that will be useful for graduation.

### 13 March, 2017

#### Features

  - When a founder gets a new verified timeline event, Vocalist sends a new notification to co-founders.
  - When a SV.CO faculty member edits the description of a timeline event, the author is notified by Vocalist of the update, along with a _diff_.

#### UX and UI

  - Initial load time of the Startup timeline page has been cut down by deferring loading of earlier events.

#### Bugfixes

  - Fixed an incorrect flash message that appeared when signing in using OAuth.
  - Fixed a crash that occurred when an unauthenticated user attempts to access a restricted founder URL.

### 6 March, 2017

#### Features

- Founders are now allowed to re-submit targets even after completion.

#### UX and UI

- The contact form was removed from `/about/contact` since using _Intercom_ is easier.

#### Bugfixes

- Vocalist pings for timeline event feedback have been restored.

### 27 February, 2017

#### Features

  - Library resources can now display embedded Youtube videos.

#### UX and UI

  - Rating titles for faculty connect requests were updated to reduce confusion about their purpose.

#### Bugfixes

  - The startup feedback mailer sent out when faculty adds feedback for a startup was broken - this has been fixed.
  - We no longer list _exited_ founders on front-end pages.
  - Fixed a crash in the startup edit form caused by presence of incorrect related data.
  - Fixed a bug in a header animation on the `/talent` page.
  - Added server-side validation for Founder's avatar image file-type - this prevents a crash if a founder attempts to upload non-image files.

### 21 February, 2017

#### Bugfixes

  - A few issues related to the assignment of karma points for improved timeline events, and _consistency_ of the weekly leaderboard, have been resolved.
  - The invite form to SV.CO's Public Slack at `/about/slack` was broken due to changes in Slack policy - this has been fixed.

### 13 February, 2017

#### Performance

  - The performance of the Founder dashboard has been greatly improved - it's about 30x faster (!) on average, on initial load.

#### UX and UI

  - We've changed the behavior of how our application handles issues related to presence of a valid authenticity token in form submissions. This eliminates occasional error messages that pop up when the web browser fails to send the expected token.
  - Improved margins of Target descriptions on the Founder dashboard for greater readability on mobile devices.

#### Bugfixes

  - Fixed a bug related to the Founder profile edit form which rendered Vocalist unable to ping founders on Slack.
  - Fixed a bug on the Founder dashboard causing filters to display targets that did not fit its criteria.
  - Fixed a crash that occurred when founders from earlier batches visited their dashboard page.
  - The leaderboard now correctly calculates the rank for startups without points for a week, when there is more than one startup sharing a rank placed above them.

### 6 February, 2017

#### Features

  - The Leaderboard has been updated to show delta from past week's position. This update applies to public leaderboard page and Vocalist's response on SV.CO's Public Slack.

#### UX and UI

  - Timeline events linked to targets now prefix its description with information about the target.
  - When responding to leaderboard requests, Vocalist now includes the time frame for which the leaderboard was generated.
  - Cleaned up uneven spacing between bullet points and paragraphs in target descriptions.

#### Bugfixes

  - `/about/slack` was displaying a missing app error from Heroku. This sign-up form for SV.CO's Public Slack has been restored.

### 30 January, 2017

#### Features

  - The admissions process has been re-worked to allow multiple rounds of admission for a single batch.
  - A new screening (first) stage has been introduced to the application process, and the combined coding and video test has been split into two separate stages.

#### UX and UI

 - The profile edit page for founders had two separate forms for basic and social-media-related information. They have been merged into one.

#### Bugfixes

- The submit feedback form was inaccessible when viewed from the home page - its styling was also broken. Both these issues have been fixed.
- The submit feedback form's horizontal resize ability has been disabled to prevent it from overflowing its container's bounds.

### 23 January, 2017

#### Features

  - Added ability to filter targets on the Founder Dashboard.

#### UX and UI

  - Timeline event descriptions now include line-breaks when being displayed in the startup timeline.
  - The application registration form and the user sign-in form now block users and display an error message if the address being used has bounced emails in the past.

#### Bugfixes

  - We've fixed a timing-related bug with the Startup Leaderboard - the results should now be accurate when viewing after midnight.

### 16 January, 2017

#### Features

  - Founders can now connect their Facebook account to auto-post timeline events to their wall upon verification.
  - Login process for applicants has been upgraded to latest method - OAuth-based login + single-use email.

#### UX and UI

  - Registration process for SixWays MOOC now supplies a searchable list of colleges (instead of asking for University and College).
  - Timeline event description length limit has been increased to 500 characters.
  - When submitting a timeline event, the form now points out if a file has been selected, but not added to list of attachments, even if the file form is closed.

#### Bugfixes

  - Fixed a bug in the rendering of cards on startups page.
  - Fixed a bug preventing Vocalist from replying to leaderboard requests from Slack channels.

### 9 January, 2017

#### Features

  - Karma Points are now automatically awarded upon verification of timeline event, based on assigned grade.

#### UX and UI

  - All buttons on the timeline builder action bar are now disabled once the submission process begins.
  - When submitting a timeline event with a file or a link, clicking the submit button now runs validations on an open file or link form, to ensure that any currently entered values are not missed out when sending data to the server.
  - Clicking the logo after being signed in now leads to founder dashboard page.
  - The check (tick) button to the right of file and link form elements in the timeline builder now reads `ADD` to clearly communicate its purpose.
  - The _Download Rubric_ button within targets on the founder dashboard now generate a S3 download link on demand, so as to prevent timeouts.

#### Bugfixes

  - There was a minor mismatch between length validation of timeline event description on the client and the server, which caused issues when max-ed out length was submitted. Some slack has been added to prevent any further issues.
  - Videos in the dashboard target slides no longer continue to play after being closed.
  - A confirmed faculty connect request now successfully creates a Google Calendar event, marking all participants - it wasn't working because of an authorization issue.
  - Timeline builder now trims the description to calculate its length and before sending it to the server.
  - Slack username validation on the Founder edit page has been updated to match Slack's latest standard.
  - Fixed an crash when revisiting the Founder edit page immediately after uploading a new avatar image.
  - The timeline builder would not open on Safari when triggered from a target which has a default timeline event type. This was caused by the presence of some ES7 Javascript that Safari couldn't parse. The ES7 segments have been replaced with ES6 for compatibility.
  - The submit feedback form available to signed-in founders had broken styling.
  - The sign-up form for SixWays MOOC was non-functional because selection of state was broken - this has been fixed.
  - Removed case-sensitivity from timeline builder's cover image file selector. This allows users to pick files with all-caps file extensions.
  - The count of participating universities shown on the home page was stuck at zero. The calculation has been fixed to match latest data.

### 2 January, 2017

#### Features

  - Batch 3 is now live! We've launched the new founder dashboard, detailing our six-month program's target framework, and a much easier method to submit timeline events and receive feedback.

#### Bugfixes

  - The form for joining our Public Slack channel was non-functional on most browsers - this has been fixed.

### 26 December, 2016

#### Features

  - We've retired the form used by founders to create new timeline events in favor of a brand new version. This will be launched along with the Founder Dashboard page for the upcoming batch.
  - We've improved the handling of invalid email addresses being
  used to sign into the website - we now store information on whether attempts to send an email to an address has bounced - so as to supply an appropriate error message instead of silently failing.

### 19 December, 2016

#### Content

  - Updated SV.CO's physical address, given on the application page.

### 12 December, 2016

#### Bugfixes

  - A signed-in user, registering for our MOOC is now taken directly to start of MOOC after registration, instead of being emailed another sign-in link.
  - The OAuth-based login process now correctly redirects users to the restricted page they were attempting to access (if any) after successful sign-in.
  - The startup team member add / edit form was non-functional. We'd introduced HTML5 client-side validations a while back, and this was blocking the form from being submitted - this has been fixed.

### 5 December, 2016

#### Features

  - Founders can now freely change their stored phone number without SMS-based validation.
  - This isn't a feature addition, but as part of one - OAuth-based login, the password change form has been removed since it is no longer needed.

### 29 November, 2016

#### Features

  - The on-boarding process of new founders has been rebuilt to require no extra action from founders, given that we've accepted most of the information we need during the application process.

#### Bugfixes

  - The live chat feature's image upload function was broken. This has been fixed.

### 21 November, 2016

#### Features

  - We've updated final stages of the application process to accept more information and generate _ready-to-sign_ documents. This is expected ot speed up on-boarding considerably.

### 14 November, 2016

#### Features

  - We're phasing out password-based login in favor of OAuth-based login (with Google, Facebook and Github). We'll keep manual login using e-mail address as a backup option for those who don't have an account at these sites.

#### Bugfixes

  - Fixed a crash on the library page when navigating to different pages.

### 7 November, 2016

#### Bugfixes

  - Fixed a minor bug related to the _Filter by Tag_ feature on the Library page.

### 31 October, 2016

#### Bugfixes

  - The styling of radio buttons in SixWays MOOC quizzes were broken by a recent change. They have been restored to their original state.

#### UX and UI

  - Minor changes to styling of library inner pages.

### 24 October, 2016

#### Bugfixes

  - The datepicker used for certain forms on the site were non-functional. These have been replaced with an updated component.

### 17 October, 2016

#### Features

  - We've opened up the applications process to international applicants!
  - Applicants are now shown their percentile scores after coding and video submission results are released.

### 10 October, 2016

#### UX and UI

  - We've released a new design for the [library](/library) index page!
  - Notifications now have _bolder_ styling with greater visibility.

#### Performance

  - SV.CO now runs on Rails 5, and uses Turbolinks 5 - the latest and greatest.

### 3 October, 2016

#### Bugfixes

  - [playbook.sv.co](https://playbook.sv.co) was serving an incorrect SSL certificate - this has been fixed. [Let’s Encrypt FTW!](https://letsencrypt.org/)
  - Improved handling of URL-s submitted by applicants during the second stage of application process.

### 19 September, 2016

#### Features

  - Instead of asking University and College information separately, the application form now asks applicant to search for, and pick just the college from a list.

#### Content

  - Deadlines for applications to Batch 4 were updated.

#### UX and UI

  - Updated footer on all pages using the latest design language.

#### Bugfixes

  - The form accepting submissions for coding and video task was rejecting URLs with `.online`, and other newer TLD-s. This has been fixed.
  - Fixed a visual bug with page header on older versions of Microsoft's Edge web browser.

### 5 September, 2016

#### Features

  - Vocalist now pings the #saas Slack channel at 9 AM, every day, with a _Term of the Day_.

#### UX and UI

  - Improved styling of the MOOC course when accessing from a mobile device.
  - Returning students can now access the course from the homepage with a helpful link.

#### Content

  - More illustrations were added to the MOOC course.
  - Applications to Batch 4 were opened, and dates were published.

#### Bugfixes

  - Some icons on application pages were invisible on Mozilla Firefox. This has been fixed.

### 29 August, 2016

#### Features

  - Our SixWays MOOC can now be previewed without supplying an email address - signing up is required to be eligible for the certificate.

#### Bugfixes

  - Fixed some bugs that could have popped up when updating or deleting timeline events.
  - Fixed a bug which allowed cofounders to login and see application state as though they were the team lead.
  - Improved handling of cases where supplied email address cannot be reached.

### 22 August, 2016

#### Features

  - Our free MOOC, [SixWays](sixways) is live. Check it out!
  - Picking a university from our select boxes should now be easier since it returns out-of-order results.

#### Content

  - Clarify dates related to the application process on the apply page.

#### Bugfixes

  - Applicants are now informed if their email address could not be reached, when attempting to send sign-in email (instead of crashing and showing a failure message).

### 15 August, 2016

#### Content, UI

  - Stage 2 (coding and video challenge) of the application process for batch #3 is now live!
  - Added lots of new content to the home page.

#### Features

  - On demand, we've modified the registration process for our SixWays MOOC to allow students from outside India to participate.

#### Bugfixes

  - Reference dropdown options on the application form weren't visible on Chrome (Windows). This has been fixed.

### 8 August, 2016

#### Content, UI

  - Our homepage is undergoing updates - new content has been added, and more is coming this week.
  - The _Startups_ page is now ordered by most recent activity.

#### Performance

  - When picking university when signing up for our MOOC, or for the latest batch, we used to preload all of the universities. Now the select box searches for, and returns only a subset of matching universities. This speeds up operation on mobiles significantly.

#### Bugfixes

  - The _Record Feedback_ option for signed-in founders went kaput. It's up and running again.
  - Founders are now asked to sign-in if they try to join a connect request. Earlier, they were met with a 404 if they weren't signed-in already.
  - Changes to the application process meant that all of the earlier sign-in mails sent to applicants contained links which 404-ed. All of those have been redirected to the new apply page.

### 1 August, 2016

#### Features

  - The widget to contact us via Facebook, Twitter or Email has been replaced! We now have a live chat function instead, active all over the site (including this page), where you can have a chat with us without any interruption. It's pretty slick, check it out!

#### UI and UX

  - Application process to batch 3 has been given a bit of an overhaul. We've altered and improved the way information is delivered to applicants, and reduced the amount of data we require for them to get started. Brand new apply page design included!
  - The latest posts from our Instagram account are now featured on the homepage!

### 25 July, 2016

#### Features

  - We introduced a widget for traffic landing on the website to contact us easily. Folks can now reach us directly through Facebook's Messenger, tweet to us, or mail us for a quick response.

#### Bugfixes

  - We'd messed up when we redirected sv.co to www.sv.co (new canonical URL), which was failing on Apple's Safari browser. This has been fixed.

#### UI and UX

  - Sign in page for existing founders has been updated to new design language.
  - Fixed broken styling of announcement headers when using new design.
  - Popup videos on apply page were not being centered correctly, and were overflowing on low-res mobiles. They now fit correctly within the viewport.

### 18 July, 2016

#### Features

  - Login e-mails are now sent immediately instead of being deferred, resulting in improved delivery times.

#### Bugfixes

  - Fixed some bugs related to addition of co-founders on batch 3's application form.
  - Apply page videos were being hidden by the floating header element on mobile view. They're now on top!

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
