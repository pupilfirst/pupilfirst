---
id: rate_limiting
title: Rate Limiting
sidebar_label: Rate Limiting
---

| model        | scope    | Condition                                      |
| ------------ | -------- | ---------------------------------------------- |
| AnswerOption | Question | A question can have 15 answer options (15)     |
| Applicant    | Course   | A course can have 10K applciants per day (10K) |
| Calendar     | Course   | A couse can have 100 calenders per week (100)  |

| CalendarEvent | Calender | A user can create 100 calendar events a day (100) |
| Certificate | Course | A course can have 100 certificates (100) |
| CoachNote | User | A User can create 100 notes every hour (100) |
| Cohort | Course | A course can have 100 cohorts per hourse (100) |
| Community | School | A school can have 100 communities (100) |
| CommunityCourseConnection | Community | A community can be connected to 50 courses (50) |
| ContentBlock | TargetVersion | A target version can have 100 content blocks (100) |
| ContentVersion | Target | A target can have 100 versions (100) |
| Course | School | A school can have 100 courses per year (100) |
| CourseAuthor | Course | A course can have 100 authors (100) |
| CourseExport | | |
| CourseExportsCohort | Cohort | A user can add 100 cohorts in an export (100) |
| Domain | School | A school can have 100 domains (100) |
| EvaluationCriterion | Course | A course can have 100 Evaluation criteria (100) |
| IssuedCertificate | Issuer | A issuer can issue 1000 certificates per hour (1000) |
| Level | Course | A course can have 25 levels (25) |
| MarkdownAttachment | User | 100 Attachments a day (100) |
| Organisation | School | 100 Organisation per day (100) |
| OrganisationAdmin | Organisation | 100 Admins per organisation (100) |
| Post | Creator | 250 Post Per hour (250) |
| PostLike | User | 250 likes per hour (250) |
| QuizQuestion | Quiz | 50 Question per Quiz (50) |
| SchoolAdmin | School | 100 admins per school (100) |
| SchoolLink | School | 25 links per school (25) |
| StartupFeedback | Submission | 25 feedbacks per submission (25) |
| Student | Cohort | 5000 students per hour per cohort (5000) |
| SubmissionReport | Submission | 25 reports per submission per hour (25) |
| Target | TargetGroup | 100 per target group (100) |
| TargetGroup | Level | 25 target group per level (25) |
| TargetPrerequisite | Target | 25 Prerequisite per target (25) |
| TargetVersion | Target | 25 Version per day (25) |
| Team | Cohort | 2500 teams per cohort per hour (2500) |
| TimelineEventFile | User | 50 file upload per hour for a user (50) |
| Topic | Community | 1000 topic per hour (1000) |
| TopicCategory | Community | 25 category per community (25) |
| WebhookEndpoint | Course | 25 Endpoint per course (25) |
