---
id: rate_limiting
title: Rate Limiting
sidebar_label: Rate Limiting
---

These are the rate limits applied to the creation of all kinds of resources stored within the LMS's database. These limits are meant to prevents users from abusing resource creation end-points, and are meant to be unrealistic numbers to reach under normal circumstances.

| Model                             | Scope         | Condition                                                     |
| --------------------------------- | ------------- | ------------------------------------------------------------- |
| AnswerOption                      | Question      | Each question can have up to 15 answer options.               |
| Applicant                         | Course        | Each course can receive up to 10,000 applicants daily.        |
| Assignment                        | Target        | Each target can have only one assignment                      |
| AssignmentsPrerequisiteAssignment | Assignment    | Each assignment can have upto 25 prerequisites                |
| Calendar                          | Course        | Each course can have up to 100 calendars weekly.              |
| CalendarEvent                     | Calendar      | Each user can create up to 100 calendar events daily.         |
| Certificate                       | Course        | Each course can issue up to 100 certificates.                 |
| CoachNote                         | User          | Each user can create up to 100 notes hourly.                  |
| Cohort                            | Course        | Each course can have up to 100 cohorts daily.                 |
| Community                         | School        | Each school can have up to 100 communities.                   |
| CommunityCourseConnection         | Community     | Each community can connect to up to 50 courses.               |
| ContentBlock                      | TargetVersion | Each target version can contain up to 100 content blocks.     |
| ContentVersion                    | Target        | Each target can have up to 100 versions.                      |
| Course                            | School        | Each school can introduce up to 100 courses annually.         |
| CourseAuthor                      | Course        | Each course can list up to 100 authors.                       |
| CourseExport                      | Course        | Each course can perform up to 25 exports hourly.              |
| CourseExportsCohort               | Cohort        | A user can add up to 100 cohorts per export.                  |
| Domain                            | School        | Each school can register up to 100 domains.                   |
| EvaluationCriterion               | Course        | Each course can define up to 100 evaluation criteria.         |
| IssuedCertificate                 | Issuer        | Each issuer can issue up to 1,000 certificates hourly.        |
| Level                             | Course        | Each course can establish up to 25 levels.                    |
| MarkdownAttachment                | User          | Each user can upload up to 100 attachments daily.             |
| ModerationReport                  | User          | Each user can create up to 100 reports hourly.                |
| Organisation                      | School        | Each school can establish up to 100 organisations daily.      |
| OrganisationAdmin                 | Organisation  | Each organisation can have up to 100 admins.                  |
| Post                              | Creator       | Creators can post up to 250 times hourly.                     |
| PostLike                          | User          | Users can like up to 250 posts hourly.                        |
| QuizQuestion                      | Quiz          | Each quiz can have up to 50 questions.                        |
| Reaction                          | User          | Each user can add up to 1000 reactions hourly.                |
| SchoolLink                        | School        | Each school can create up to 25 links.                        |
| StartupFeedback                   | Submission    | Each submission can receive up to 25 feedbacks.               |
| Student                           | Cohort        | Each cohort can admit up to 5,000 students hourly.            |
| Standing                          | School        | Each school can create upto 15 standings.                     |
| SubmissionComment                 | User          | Each user can create up to 300 comments hourly.               |
| SubmissionReport                  | Submission    | Each submission can receive up to 25 reports hourly.          |
| Target                            | TargetGroup   | Each target group can have up to 100 targets.                 |
| TargetGroup                       | Level         | Each level can contain up to 25 target groups.                |
| TargetVersion                     | Target        | Each target can get up to 25 versions daily.                  |
| Team                              | Cohort        | Each cohort can form up to 2,500 teams hourly.                |
| TimelineEventFile                 | User          | Each user can upload up to 50 files hourly.                   |
| Topic                             | Community     | Up to 1,000 topics can be created hourly.                     |
| TopicCategory                     | Community     | Each community can have up to 25 categories.                  |
| UserStanding                      | User          | Each admin can create up to 5000 standing log entries hourly. |
| UserStanding                      | User          | Each user can have up to 100 standing log entries.            |
| WebhookEndpoint                   | Course        | Each course can set up to 25 endpoints.                       |
