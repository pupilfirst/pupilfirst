type t =
  | Preview
  | CourseEnded
  | CourseComplete
  | AccessEnded
  | LevelUp
  | Nothing;

let courseEndedImage: string = [%raw "require('../images/course-ended.svg')"];
let courseCompleteImage: string = [%raw
  "require('../images/course-complete.svg')"
];
let accessEndedImage: string = [%raw "require('../images/access-ended.svg')"];
let levelUpImage: string = [%raw "require('../images/level-up.svg')"];
let previewModeImage: string = [%raw "require('../images/preview-mode.svg')"];

let icon = t =>
  switch (t) {
  | Preview => previewModeImage
  | CourseEnded => courseEndedImage
  | CourseComplete => courseCompleteImage
  | AccessEnded => accessEndedImage
  | LevelUp => levelUpImage
  | Nothing => levelUpImage
  };
