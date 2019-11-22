# Curriculum Editor

At PupilFirst, we believe that actions speak louder than words, and that (when possible) it's always better to give your students things to _do_, rather than information to simply _consume_.

However, your students will always need instruction before they can effectively take any action. These instructions will need to be laid out in a path whose route is clear, and with a visible end-point. The curriculum editor is designed to make this possible.

The curriculum editor organizes content into _levels_, which contains many _groups_ of _targets_, each of which can hold the text and other rich media that you want your students to see.

![Curriculum editor in the school administration interface](https://res.cloudinary.com/sv-co/image/upload/v1574237953/pupilfirst_documentation/curriculum_editor/curriculum_editor_page_j13pxw.png)

## What are levels?

Levels are the top organizational unit within a course, and act as an indicator for the progress of a student.

1. Levels can hold many _groups_ of targets.
2. All students begin in the first level - **Level 1**.
3. Students can move up through levels, after they've submitted work on [milestone targets](/targets?id=milestone-targets). We call this _leveling up_, or to _level up_.
4. Courses can have any number of levels, but you probably don't want to go overboard.

?> **For all the non-gamers out there:** The phrase _level up_, is borrowed from the world of gaming. Roughly, it means _to progress to the next level_ - an activity that is common in modern role-playing games where one's character advances to the next level of development.

To create a new level, click the _Create Level_ button next to the level selector, and to edit a level's name, click the _edit icon_ next to the selected level. Levels have one additional property: a date to _Unlock level on_. If set, the _content_ of the level is hidden from the student until that date.

?> **What purpose does a level's _unlock date_ serve?**\
Locked levels are still _visible_ to a student, but it's content (targets) are not. This can be used to communicate to the student about the _path_ they're expected to follow, but to deliberately hide the exact content they'll get access to. For example, this can be useful if the content for a level is still a work-in-progress, but the overall organization of the course is fixed.

## What's a target group?

Similar targets can be grouped together into target groups. This allow you to organize content into discrete chunks in a way that makes sense for what you're trying to teach. To create a target group, just click the _Create a target group_ button within a level.

When creating and editing a target group, you can decide whether it's a _milestone_ target group or not. Milestone targets control a student's progression in the course. To learn more, [check out the documentation for milestone targets](/targets?id=milestone-targets).

## Creating targets

To create a target, click the _Create a target_ option inside a target group, enter a name, and hit the _Create_ button. This will create a new target with that name in the target group, and will set it to the _Draft_ status.

## Editing target content

After creating a target, you can click on it in the curriculum to open the target editor. It will open up in the _preview_ mode.

![Target editor, in preview mode](https://res.cloudinary.com/sv-co/image/upload/v1574148290/pupilfirst_documentation/curriculum_editor/target_editor_preview_mode_froofq.png)

To switch to editing the target, switch to the _Edit_ mode. You can now edit and add new blocks of content. You'll notice that you can add different types of these _content blocks_.

![Target editor content blocks](https://res.cloudinary.com/sv-co/image/upload/v1574148406/pupilfirst_documentation/curriculum_editor/target_editor_blocks_bi80cn.png)

### Content block types

At the moment, we support four types of content blocks:

**Markdown**\
The Markdown block allows you to write formatted text in the Markdown format. You can also embed files and images directly into the text using the file upload feature here, but you'll have no control over how they're displayed. Images will be centered, and displayed at actual size, whereas files will be inserted as links. Use the _Image_ and _File_ block types for greater control over these kinds of content.

![Markdown Editor](https://res.cloudinary.com/sv-co/image/upload/v1574148846/pupilfirst_documentation/curriculum_editor/markdown_editor_y8tpqk.png)

To learn more about using the Markdown editor to format text, click on the _Need help?_ link at the bottom right of the editor. It'll take you to documentation served within the platform which details everything you can do with Markdown.

**Image**\
The image block accepts an image file and a caption and displays it, cetner with the other content.

?> We're working on improving this feature to let you to decide sizing of the image.

**Embed**\
The embed function allows you to embed content from third-party websites - all you need to do is supply the full link of the resource that you're trying to embed, and it'll get converted into its embedded format automatically.

Currently supported web services:

- YouTube
- Slideshare
- Vimeo

If there's a specific website you'd like us to include, [please let us know](mailto:support@pupilfirst.com). We can include any web service that supports the Open Embed standard (oEmbed).

**File**\
The file block accepts the file and a caption and displays it as a distinctly styled block in the content of the target.

## Setting the method of completion

Editing the content of a target is the first step in setting it up. You can switch to the second step, _Method of Completion_, using the tab at the top of the target editor, or a link at the bottom.

The method of completion tab lets you decide how your students can complete the target. It asks a few questions:

**Any prerequisite target?**\
You can select other targets from the same level as pre-requisite targets. This will _lock_ the target until the student has completed the prerequisites.

**Is this target reviewed by a coach?**\
If you would like a coach to review a submission from a student - pick _Yes_ here. If you'd like the student to complete the target on their own, pick _No_.

**Choose evaluation criteria from your list**\
This list will appear only if you've chosen to have the target's submission reviewed by a coach. Pick at least one evaluation criteria that the coach should use when reviewing submissions from students for this target.

**How do you want the student to complete the target?**\
If you answered _No_ to whether a coach will review submissions for the target, then you'll need to pick one of three ways by which a student can complete the target on their own:

1. Simply mark the target as completed: No additional steps.
2. Visit a link to complete the target: You'll be asked for the link.
3. Take a quiz to complete that target: You'll need to prepare a quiz - the process for this is detailed below.

**Do you have any completion instructions for the student?**\
Text entered here will be displayed right next to where the students take action on a target. For targets that are simply marked as complete or completed by visiting a link, this will be at the end of the main content, next to the button that completes the target. For quizzes and reviewed submissions, this will be at the top of the page that displays the quiz, or the submission form.

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
