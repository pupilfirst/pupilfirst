# Targets

Targets hold the content for a course's curriculum, and is the main objects that students interact with as a part of your courses. The creation and editing of targets is done within [the curriculum editor](/curriculum_editor). This document has additional information about targets and their behavior.

## Milestone targets

To qualify for levelling up, students must complete what are known as milestone targets. These are groups of targets that must be attempted for the student to be able to level up.

In the curriculum editor, you can mark your choice of target _groups_ as milestone. If a group is thus marked, all targets within the group will count as milestone targets. It's possible to have multiple milestone groups within a level.

### Possible questions

**What happens if I don't mark any target group as milestone?**

If a level doesn't contain at least one milestone target group, students will not be shown the option to level up. PupilFirst checks for the submission of milestone targets to determine whether a student can level up.

**What if I want my students to complete every target? Do I have to mark all target as milestones?**

Not necessarily. Remember that you can set targets as pre-requisites for others. Technically, you can set up a chain of targets, one depending on the completion of another to ensure that students complete all targets.

How you organize the content is ultimately up to you. We've deliberately made content organization flexible because the way you organize content will depend on the nature of the content, and in what order (if any) you want students to tackle your material.

## Locked targets

Students are unable to complete locked targets. There are four situations in which a target can be _locked_ for a student:

1. The target is in a level that the student hasn't reached.
2. The target has other targets as pre-requisites that the student hasn't completed.
3. The student's access to the course has ended, because of which they have read-only access to the course content.
4. The course's [end date](/courses?id=creating-courses) has passed.
5. The target in question is a _milestone_ target, and students haven't gotten a passing grade in all of _last_ level's reviewed milestone targets.

The first four should feel straight-forward, but there's a bit to unpack in the fifth case:

1. You've already seen that targets can be reviewed, and that coaches can assign failing grades.
2. Students are allowed to level up as soon as they've submitted work on all their milestone targets. This is allowed so that students aren't held up by delays that can occur in reviewing student submissions.
3. However, students shouldn't be allowed to _continue_ leveling up until their previous level's milestone targets have been confirmed as having qualified for the minimum passing grade.

This means that a student who is _locked_ in this way will need to re-submit work on the failed target again and get a passing grade before they're allowed to work on the milestone targets that are in their _current_ level.
