# Curriculum Editor

At Pupilfirst, we believe that actions speak louder than words, and that (when possible) it's always better to give your students things to _do_, rather than information to simply _consume_.

However, your students will always need instruction before they can effectively take any action. These instructions will need to be laid out in a path whose route is clear, and with a visible end-point. The curriculum editor is designed to make this possible.

The curriculum editor organizes content into _levels_, which contains many _groups_ of _targets_, each of which can hold the text and other rich media that you want your students to see.

![Curriculum editor in the school administration interface](https://res.cloudinary.com/sv-co/image/upload/v1579025594/pupilfirst_documentation/curriculum_editor/curriculum_editor_page_nx0fbq.png)

## What are levels?

Levels are the top organizational unit within a course, and act as an indicator for the progress of a student.

1. Levels can hold many _groups_ of targets.
2. All students begin in the first level - **Level 1**.
3. Students can move up through levels, after they've submitted work on [milestone targets](/targets?id=milestone-targets). We call this [leveling up](/taking_courses?id=leveling-up), or to _level up_.
4. Courses can have any number of levels, but you probably don't want to go overboard.

?> **For all the non-gamers out there:** The phrase _level up_, is borrowed from the world of gaming. Roughly, it means _to progress to the next level_ - an activity that is common in modern role-playing games where one's character advances to the next level of development.

To create a new level, click the _Create Level_ button next to the level selector, and to edit a level's name, click the _edit icon_ next to the selected level. Levels have one additional property: a date to _Unlock level on_. If set, the _content_ of the level is hidden from students until that date. Coaches in a course, and all school admins will still have access to the content of locked levels.

?> **What purpose does a level's _unlock date_ serve?**\
Locked levels are still _visible_ to a student, but it's content (targets) are not. This can be used to communicate to the student about the _path_ they're expected to follow, but to deliberately hide the exact content they'll get access to. For example, this can be useful if the content for a level is still a work-in-progress, but the overall organization of the course is fixed.

### Level actions

In addition to editing the name of the level and its unlock date, you can switch to the _Actions_ tab wherein you have the possibility to merge the current level to another level. Please note that merging levels will move all the students and targets from the current level to the level you are merging into.

## What's a target group?

Similar targets can be grouped together into target groups. This allow you to organize content into discrete chunks in a way that makes sense for what you're trying to teach. To create a target group, just click the _Create a target group_ button within a level.

When creating and editing a target group, you can decide whether it's a _milestone_ target group or not. Milestone targets control a student's progression in the course. To learn more, [check out the documentation for milestone targets](/targets?id=milestone-targets).

The editor for a target group also allows you to change the level it belongs to and to archive it. Archiving will have a target group along with its targets removed from the student curriculum.

## Creating targets

To create a target, click the _Create a target_ option inside a target group, enter a name, and hit the _Create_ button. This will create a new target with that name in the target group, and will set it to the _Draft_ status.

## Editing target content

After creating a target, you can click on it in the curriculum to open the target editor, which has three tabs: _Content_, _Details_ and _Versions_.

Clicking on a target will open the _Content_ tab by default, which allows you to edit the content of the target - this the _body_ of the material that you would like your student to read or watch.

![Target editor, in preview mode](https://res.cloudinary.com/sv-co/image/upload/v1581450578/pupilfirst_documentation/curriculum_editor/target_content_editor_feiqdh.png)

You'll notice that the content is made up of different types of _content blocks_. If you hover over the region between any of the existing blocks, you'll find an option to insert a new content block into that space. There will always be a content block picker visible at the bottom of the existing content.

![Target editor content blocks](https://res.cloudinary.com/sv-co/image/upload/v1581450578/pupilfirst_documentation/curriculum_editor/target_editor_blocks_xnvkky.png)

### Content block types

At the moment, we support four types of content blocks.

**Markdown**\
The Markdown block allows you to write formatted text in the Markdown format. You can also embed files and images directly into the text using the file upload feature here, but you'll have no control over how they're displayed. Images will be centered, and displayed at actual size, whereas files will be inserted as links. Use the _Image_ and _File_ block types for greater control over these kinds of content.

![Markdown Editor](https://res.cloudinary.com/sv-co/image/upload/v1581450985/pupilfirst_documentation/curriculum_editor/markdown_editor_xecdd0.png)

To see a live preview of the content you're creating in the editor, choose the split-screen option at the top-right of the editor, and it'll switch to a full-screen mode that shows the content you're writing on the left, with its preview on the right.

If you're unfamiliar with the Markdown format, or to brush up on how to use Markdown to quickly and effectively format text, click on the _Need help?_ link at the bottom right of the editor. It'll take you to documentation served within the platform which details everything you can do with Markdown.

**Image**\
The image block accepts an image file and a caption and displays it, centered with the other content. You can also customize the width of the displayed image by hovering over the image and choosing one of the available options.

**Embed**\
The embed function allows you to embed content from third-party websites - all you need to do is supply the full link of the resource that you're trying to embed, and it'll get converted into its embedded format automatically.

Currently supported web services:

- YouTube
- Slideshare
- Vimeo
- Google (Docs, Slides, Spreadsheets, Forms)

If there's a specific website you'd like us to include, [please let us know](mailto:support@pupilfirst.com). We can include any well-known service that supports the Open Embed (oEmbed) standard, or if it supports being embedded using an `iframe` tag.

**File**\
The file block accepts the file and a caption and displays it as a distinctly styled block in the content of the target.

## Editing a target's other details

The _Details_ tab can be accessed by clicking on the tab once the editor is open, or by clicking the _details icon_ on each of the listed targets.

This tab contains other basic details and configuration for the target, such as its name, whether it has prerequisites, its completion method, and its visibility to the student and other course authors.

### Setting the method of completion

To decide how a student can complete a target, this interface asks you a few questions:

**Are there any prerequisite targets?**\
You can select other targets from the same level as pre-requisite targets. This will _lock_ the target until the student has completed the prerequisites.

**Will a coach review submissions on this target?**\
If you would like a coach to review a submission from a student - pick _Yes_ here. If you'd like the student to complete the target on their own, pick _No_.

**Choose evaluation criteria from your list**\
This list will appear only if you've chosen to have the target's submission reviewed by a coach. Pick at least one evaluation criteria that the coach should use when reviewing submissions from students for this target.

**How do you want the student to complete the target?**\
If you answered _No_ to whether a coach will review submissions for the target, then you'll need to pick one of three ways by which a student can complete the target on their own:

1. Simply mark the target as completed: No additional steps.
2. Visit a link to complete the target: You'll be asked for the link.
3. Take a quiz to complete that target: You'll need to prepare a quiz - the process for this is detailed below.

**How should teams tackle this target?**\
If you have students grouped into teams, then you'll probably have some targets that you'd like them to tackle together. When creating a new target, this setting will default to _All students must submit individually_, which means that each student will need to submit on their own. If it's a reviewed milestone target, then all students in the team will need to pass for the team to [be eligible to level up](/taking_courses?id=leveling-up).

For those targets where you expect students to work together and submit as a _unit_, you can choose the _Only one student in a team needs to submit_ option. Now, if any student in a team submits work on the target, the submission will be credited to all students in the team. If work on the target is reviewed by a coach, then the name of all students in the team will be listed next to the submission, and any feedback on the submission will be sent to all linked students.

**Do you have any completion instructions for the student?**\
Text entered here will be displayed right next to where the students take action on a target. For targets that are simply marked as complete or completed by visiting a link, this will be at the end of the main content, next to the button that completes the target. For quizzes and reviewed submissions, this will be at the top of the page that displays the quiz, or the submission form.

### Defining steps to complete a target

For targets that require students to submit work for review, you can define the steps that a student needs to take to submit their work.

Each step needs to have a _title_ and an _action type_. Together, they define how a student completes the step. The _title_ is generally used to give a short description of what's expected from the student to complete the step. These are different possible action types:

1. **Write Long Text:** Allows the student to write paragraphs of text.
2. **Write Short Text:** Allows the student to write a single line of text.
3. **Attach a Link:** Allows the student to attach a single URL.
4. **Upload Files:** Allows the student to attach files to complete the step. Only one of this type of question is allowed as a step, and up to 3 files can be attached such a step (max 5 MB, each).
5. **Choose from a list:** Student is shown a list of choices, from which they can pick one; you decide what the choices are.

Here's an example target consisting, of four steps to complete the target:
![Adding a target checklist](https://res.cloudinary.com/sv-co/image/upload/v1583171215/pupilfirst_documentation/curriculum_editor/target_checklist_editor_eguduz.png)

Apart from _title_ and _action type_, you can make any step _optional_. Optional steps can be skipped by students when submitting a target. In the example above, step 2 of type _Attach a Link_ is optional.

You can also change the order of steps, remove a particular step, or even duplicate an existing step using the control icons that are available to the right of each step.

Here are some other points to keep in mind:

1. The maximum number of steps allowed in a target is 15.
2. The _Upload Files_ action type is allowed only once in a target. All other action types can be used multiple times.
3. You are allowed to create an evaluated target without any steps. However, this would mean that a student can _submit_ work on a target without actually providing any information. This would still require the coach to review an empty submission. This option can be used for cases where the work in question is done _outside_ of the platform and is known to the coach.

Once all steps are defined, students can submit the target by executing the required steps and a coach gets to see the response from students for each step.

Here's an example of how a target's steps are shown in the student submission interface and in the coach review interface:

![Target checklist lifecycle](https://res.cloudinary.com/sv-co/image/upload/v1583213540/pupilfirst_documentation/curriculum_editor/target_checklist_steps_flwajd.jpg)

### Preparing a quiz

If you opted to let the student answer a quiz to complete the target, then you'll need to prepare one:

![Preparing a quiz](https://res.cloudinary.com/sv-co/image/upload/v1574151702/pupilfirst_documentation/curriculum_editor/quiz_preparation_bihhl9.png)

1. The quiz supports Markdown in both questions and answers.
2. Every question must have at least two options.
3. You can have any number of questions.

### Target visibility

You'll find the _visibility_ setting at the very end of step 2. This setting has three options:

1. **Live:** Target will be visible to students.
2. **Draft:** Target will be visible only within the curriculum editor.
3. **Archived:** Target will be hidden. You can still access it through the _Show Archived_ button at the top-right of the curriculum editor interface. It'll appear only if you have archived targets in the selected level.

## Target content versions

The third tab of the target editor is called _Versions_. Just like the _Details_ tab, _Versions_ can be accessed by clicking on the tab once the editor is open, or by clicking the versions icon on each of the listed targets.

This tab shows you a preview of a target's content as it appears now to the student. But more importantly, it allows you to save the current state of the content as a version, browse previous versions to see how the target's content looked earlier, and restore an old version.

![Browsing previous versions of a target's contents](https://res.cloudinary.com/sv-co/image/upload/v1581452180/pupilfirst_documentation/curriculum_editor/versions_qtt3j8.png)

When a target is first created, you're assumed to be working on its first version. Once you've worked on the target's content for a while, and are happy with it's state, the _Versions_ tab will allow you to _save that version_. Saving a version will create a new version which will hold future changes.

?> **What exactly is a _version_?**\
A version can be thought of as a _snapshot_ of a target's content as it looked at the time it was taken. However, you're always working on the _current_ version of the target, so that can always be changed an author. You'll need to take a _snapshot_ manually on the versions tab for a new version to be created. As the author of a target, you're the best person to decide when it's appropriate to preserve a version.

This feature allows you to preserve a _known good state_ for a target's content, and since you can browse previous versions of a target, it can help track changes to the content, or even act as a safeguard, by allowing you to _restore a previous version_ if something goes awry during the editing process.
