# Courses

Courses hold your content and can have any number of students enrolled, with coaches to guide their path.

## Creating courses

To create a new course, head to the Courses menu from the school administration interface's navigation bar, and click the _Add New Course_ button at the top of the page.

![Courses page in school administration interface](https://res.cloudinary.com/sv-co/image/upload/v1574237472/pupilfirst_documentation/courses/courses_page_p8p5tg.png)

The form that pops up will ask you for a few details:

**Name**\
The name of the course, that will publicly displayed.

**Course description**\
This short description will be displayed on the course's public page.

**Course end date**\
If set, your course will go into a _read-only_ mode after this date, and students will be shown a message that the course has ended. This effectively _closes_ the course, preventing students from making further submissions, but does not remove student's access to the content, or to the work that they submitted as a part of the course.

**About**\
This is a markdown field - you can use this to add descriptive text about your course. This will be displayed on the on the course's public page.

**Enable public signup for this course?**\
If enabled, members of the public will be able to sign up for your course.

**Grades**\
These are the grades that coaches can assign when they're reviewing a student's submission. You'll need to set a maximum grade (up to 10), and a minimum passing grade, and assign labels to each grade.

- If the passing grade is set to 1, then it will be impossible for students to _fail_ during grading.
- The labels for each grade helps to give them meaning, and to differentiate them for coaches.

!> This mechanics of grading will change soon. See the [related issue on Github](https://github.com/SVdotCO/pupilfirst/issues/14) for more details.

## Editing courses

To edit a course's details, simply click on the course in the Courses menu. The form for editing a course is identical to the one that you used to create it.

To edit the _contents_ of a course, you'll want to use the [curriculum editor](/curriculum_editor?id=curriculum-editor), which is documented separately.

## Course Images

!> This feature is a work in progress. Please check [the related Github issue](https://github.com/SVdotCO/pupilfirst/issues/66) for updates.

You can customize how the course looks to the student by editing two images:

### Thumbnail

This image will be displayed in the user's home page, when listing the courses that the student has access to.

The image should have an aspect ratio of 2:1, with a suggested resolution of `768x384` (WxH).

### Cover

This image will be displayed in all pages _within_ a course. It's the large header image that appears at the top of every course page.

Because this image fits with the width of the page, it should be created following a few guidelines:

1. The aspect ratio of the image should be 4:1. The suggested resolution is `1920x480` (WxH).
2. Text within the cover image should be restricted to the center portion of the image. This is because the image width will be considerably smaller on mobile screens, and its height is restricted on larger screens.
3. We suggest using an image with a dark background for improved contrast with the site's header and the rest of the page's content.

Here's an example image that shows where you should place text in a cover image:

[![Cover image composition](https://res.cloudinary.com/sv-co/image/upload/v1574756690/pupilfirst_documentation/courses/cover_composition_hztuof.png)](https://res.cloudinary.com/sv-co/image/upload/v1574756690/pupilfirst_documentation/courses/cover_composition_hztuof.png)
