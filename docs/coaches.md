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

**Connect Link**\
When a coach is publicly listed, this link will also be displayed on the `/coaches` page. This link can be used to allow students to connect with a coach outside of the platform, via tools such as _Calendly_.

## Assigning coaches to students

Once a coach has been added to a school, they can immediately access all communities. However, to review submissions from students, they must be assigned to students in one of two ways:

### Course Coaches

To assign a coach to a course, head to the _Coaches_ sub-menu inside a course:

![Coaches assigned to a course](https://res.cloudinary.com/sv-co/image/upload/v1589824687/pupilfirst_documentation/coaches/course_coaches_page_jql0rz.png)

This assignment allows coaches to review submissions from _all_ students in a course. For courses with small numbers of students, this is probably sufficient configuration.

However, if your list of students is large, you may want to split the reviewing workload among a number of coaches. This is made easier by directly assigning course coaches to students.

### Assigning coaches to students and teams

Head to the list of students in a course, and select any student to edit their details. If you've picked a team, you'll notice a field titled _Team Coaches_, and if you've picked a lone student, then the same field would be labled _Personal Coaches_.

This editable list of coaches allows you to directly assign coaches to a student or a team.

The makes a few changes across Pupilfirst:

1. The list of [submissions to review](/reviewing_submissions) can now be filtered by selecting an _assigned coach_.
2. When a coach with directly assigned students loads the page for the first time, the filter defaults to show them only submissions from their own students.
3. When viewing the details of a submission, the directly assigned coaches are listed at the top.
4. When browsing the coach's [students list](/student_reports), similar filters are available, and the assigned coaches are listed on both the _index_ page, and within the student report itself.

?> Having multiple coaches to handle reviewing of submissions can come in really handy at times. This allows coaches to do something as simple as take a few days off, asking a peer to take care of their students. If students are directly assigned, then the filtering functions that are available in the coach's review interface and students list makes finding applicable submissions and students simple.
