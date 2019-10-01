[@bs.config {jsx: 3}];

let courseEndedImage: string = [%raw "require('../images/course-ended.svg')"];
let courseCompleteImage: string = [%raw
  "require('../images/course-complete.svg')"
];
let accessEndedImage: string = [%raw "require('../images/access-ended.svg')"];
let levelUpImage: string = [%raw "require('../images/level-up.svg')"];

open CoursesCurriculum__Types;

type notice =
  | CourseEnded
  | CourseComplete
  | AccessEnded
  | LevelUp
  | None;

let str = React.string;

let iconsForNotice = showNotice =>
  switch (showNotice) {
  | CourseEnded => courseEndedImage
  | CourseComplete => courseCompleteImage
  | AccessEnded => accessEndedImage
  | LevelUp => levelUpImage
  | None => levelUpImage
  };

let showNotice =
    (
      ~title,
      ~description,
      ~noticeType,
      ~classes="max-w-3xl mx-auto text-center mt-4 bg-white rounded-lg shadow-lg px-6 pt-4 pb-8",
      (),
    ) =>
  <div className=classes>
    <img className="w-64 mx-auto" src={iconsForNotice(noticeType)} />
    <div
      className="max-w-xl font-semibold text-2xl mx-auto mt-1 leading-tight">
      {title |> str}
    </div>
    <div className="text-sm max-w-lg mx-auto mt-2"> {description |> str} </div>
  </div>;

let courseCompletedMessage = () => {
  let title = "Congratulations! You have completed all milestone targets in this course.";
  let description = "You've completed our Level Framework, but you know by now that this is just the beginning of your journey.
  Feel free to complete targets that you might have left out, read up on attached links and resources, and work on the breadth and depth of your skills.";
  showNotice(~title, ~description, ~noticeType=CourseComplete, ());
};

let courseEndedMessage = () => {
  let title = "Course Ended";
  let description = "The course has ended and submissions are disabled for all targets!";
  showNotice(~title, ~description, ~noticeType=CourseEnded, ());
};

let accessEndedMessage = () => {
  let title = "Access Ended";
  let description = "Your access to this course has ended.";
  showNotice(~title, ~description, ~noticeType=AccessEnded, ());
};

let renderLevelUp = (course, authenticityToken) => {
  let title = "Ready to Level Up!";
  let description = "Congratulations! You have successfully completed all milestone targets required to level up. Click the button below to proceed to the next level. New challenges await!";
  <div
    className="max-w-3xl mx-auto text-center mt-4 bg-white rounded-lg shadow-lg px-6 pt-4 pb-8">
    {showNotice(~title, ~description, ~noticeType=LevelUp, ~classes="", ())}
    <CoursesCurriculum__LevelUpButton course authenticityToken />
  </div>;
};

let computeLevelUp =
    (levels, teamLevel, targetGroups, targets, statusOfTargets) => {
  let targetGroupsInLevel =
    targetGroups
    |> List.filter(tg => tg |> TargetGroup.levelId == (teamLevel |> Level.id));
  let milestoneTargetGroupIds =
    targetGroupsInLevel
    |> List.filter(tg => tg |> TargetGroup.milestone)
    |> List.map(tg => tg |> TargetGroup.id);

  let milestoneTargetIds =
    targets
    |> List.filter(t =>
         (t |> Target.targetGroupId)->List.mem(milestoneTargetGroupIds)
       )
    |> List.map(t => t |> Target.id);

  let statusOfMilestoneTargets =
    statusOfTargets
    |> List.filter(ts =>
         (ts |> TargetStatus.targetId)->List.mem(milestoneTargetIds)
       );

  let nextLevelNumber = (teamLevel |> Level.number) + 1;

  let nextLevel =
    levels |> ListUtils.findOpt(l => l |> Level.number == nextLevelNumber);

  let canLevelUp =
    statusOfMilestoneTargets
    |> ListUtils.isNotEmpty
    && statusOfMilestoneTargets
    |> TargetStatus.canLevelUp;

  switch (nextLevel, canLevelUp) {
  | (Some(level), true) => level |> Level.isLocked ? None : LevelUp
  | (None, true) => CourseComplete
  | (Some(_) | None, false) => None
  };
};

let computeNotice =
    (levels, teamLevel, targetGroups, targets, statusOfTargets, course, team) =>
  switch (course |> Course.hasEnded, team |> Team.accessEnded) {
  | (true, true | false) => CourseEnded
  | (false, true) => AccessEnded
  | (false, false) =>
    computeLevelUp(levels, teamLevel, targetGroups, targets, statusOfTargets)
  };

[@react.component]
let make =
    (
      ~levels,
      ~teamLevelId,
      ~targetGroups,
      ~targets,
      ~statusOfTargets,
      ~course,
      ~team,
      ~authenticityToken,
    ) => {
  let teamLevel =
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == teamLevelId,
         "Could not find teamLevel with ID " ++ teamLevelId,
       );

  let (showNotice, _) =
    React.useState(() =>
      computeNotice(
        levels,
        teamLevel,
        targetGroups,
        targets,
        statusOfTargets,
        course,
        team,
      )
    );

  switch (showNotice) {
  | CourseEnded => courseEndedMessage()
  | CourseComplete => courseCompletedMessage()
  | AccessEnded => accessEndedMessage()
  | LevelUp => renderLevelUp(course, authenticityToken)
  | None => React.null
  };
};
