[@bs.config {jsx: 3}];

let levelUpImage: string = [%raw "require('../images/level-up.svg')"];

open CourseShow__Types;

type notice =
  | CourseEnded
  | CourseComplete
  | AccessEnded
  | LevelUp
  | None;

let str = React.string;

let iconsForNotice = showNotice =>
  switch (showNotice) {
  | CourseEnded
  | CourseComplete
  | AccessEnded
  | LevelUp
  | None => levelUpImage
  };

let showNotice = (title, description, showNotice) =>
  <div
    className="max-w-3xl mx-auto text-center mt-4 bg-white rounded-lg shadow-lg p-6">
    <img className="w-20 mx-auto" src={iconsForNotice(showNotice)} />
    <div className="max-w-xl font-semibold text-2xl mx-auto">
      {title |> str}
    </div>
    <div className="text-sm max-w-xl mx-auto"> {description |> str} </div>
  </div>;

let courseCompletedMessage = () => {
  let title = "Congratulations! You have completed all milestone targets in this course.";
  let description = "You've completed our Level Framework, but you know by now that this is just the beginning of your journey.
  Feel free to complete targets that you might have left out, read up on attached links and resources, and work on the breadth and depth of your skills.";
  showNotice(title, description, CourseComplete);
};

let courseEndedMessage = () => {
  let title = "Course Ended";
  let description = "The course has ended and submissions are disabled for all targets!";
  showNotice(title, description, AccessEnded);
};

let accessEndedMessage = () => {
  let title = "Access Ended";
  let description = "Your access to course has ended.";
  showNotice(title, description, AccessEnded);
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

  let canLevelUp = statusOfMilestoneTargets |> TargetStatus.canLevelUp;

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
      ~teamLevel,
      ~targetGroups,
      ~targets,
      ~statusOfTargets,
      ~course,
      ~team,
      ~authenticityToken,
    ) => {
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
  | LevelUp => <CourseShow__LevelUp course authenticityToken />
  | None => React.null
  };
};
