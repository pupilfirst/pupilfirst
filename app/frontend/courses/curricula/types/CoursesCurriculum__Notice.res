type rec t =
  | Preview
  | CourseEnded
  | CourseComplete
  | AccessEnded
  | LevelUp
  | LevelUpLimited(currentLevelNumber, minimumRequiredLevelNumber)
  | LevelUpBlocked(currentLevelNumber, someSubmissionsRejected) // For when the Strict progression behavior applies.
  | TeamMembersPending
  | Nothing
and currentLevelNumber = int
and minimumRequiredLevelNumber = int
and someSubmissionsRejected = bool

@bs.module external courseEndedImage: string = "../images/course-ended.svg"
@bs.module
external courseCompleteImage: string = "../images/course-complete.svg"
@bs.module external accessEndedImage: string = "../images/access-ended.svg"
@bs.module external levelUpImage: string = "../images/level-up.svg"
@bs.module external previewModeImage: string = "../images/preview-mode.svg"
@bs.module
external levelUpBlockedImage: string = "../images/level-up-blocked.svg"

let icon = t =>
  switch t {
  | Preview => previewModeImage
  | CourseEnded => courseEndedImage
  | CourseComplete => courseCompleteImage
  | AccessEnded => accessEndedImage
  | LevelUp => levelUpImage
  | LevelUpLimited(_)
  | LevelUpBlocked(_)
  | TeamMembersPending => levelUpBlockedImage
  | Nothing => ""
  }
