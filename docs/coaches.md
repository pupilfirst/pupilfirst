# Coaches

Pupilfirst enables quick and efficient review of task submissions by students, and to share feedback and create a conversation around what students have learned from a course. Coaches are users who make this possible.

1. Coaches are users who can review submissions from students.
2. Coaches also have access to all communities in a school.

## Adding and editing coaches

Coaches can be added from the coaches page which is linked on the main navigation bar of the school administration interface.

![Coaches page in school administration interface](https://res.cloudinary.com/sv-co/image/upload/v1574236845/pupilfirst_documentation/coaches/coaches_page_xjrmba.png)

You can add new coaches using the _Add New Coach_ option, and edit them by clicking on the name on this list. Coaches have a few additional properties unique to them:

**Should the coach profile be public?**\
If this option is turned on for at least one coach, it will enable the public coaches index page at the `/coaches` path on your school. This page will list coaches that have been marked public using this setting.

**Should the coach be notified of student submissions?**\
Enabling this setting will cause the platform to notify coaches via email for new submissions from students that they are assigned to.

**Connect Link**\
When a coach is publicly listed, this link will also be displayed on the `/coaches` page. This link can be used to allow students to connect with a coach outside of the platform, via tools such as _Calendly_.

## Assigning coaches to students

Once a coach has been added to a school, they can immediately access all communities. However, to review submissions from students, they must be assigned to students in one of two ways:

### Course Coaches

To assign a coach as a _course coach_, jump into a course, and head to the _Coaches_ submenu:

![Coaches assigned to a course](https://res.cloudinary.com/sv-co/image/upload/v1574237288/pupilfirst_documentation/coaches/course_coaches_page_ldxjjs.png)

_Course_ coaches have the permission to review submissions from _all_ students in a course. This is appropriate if you have a small group of students in a course, or if a coach is has an _overseer_ position within the list of coaches.

However, if your list of students is large, then you may not want to give access to submissions from all students. In order to split the reviewing workload, you can directly assign students or teams to one or more coaches.

### Student / Team coaches

Head to the list of students in a course, and select any student to edit their details. If you've picked a team, you'll notice a field titled _Team Coaches_, and if you've picked a lone student, then the same field would be labled _Personal Coaches_.

This editable list of coaches allows you to directly assign coaches to a student or a team. Coaches in this list will only have access to submissions from students to whom they are directly linked. Note that if a student is teamed up, then a coach will have access to submissions from all students in that team.

?> Given that a course coach has access to all students, assigning an existing student or _team coach_ as a _course coach_ will remove the entry from the student's edit panel, since a direct assignment is no longer necessary. Similarly, course coaches will not be available as an option in the student edit panel for direct assignment.
