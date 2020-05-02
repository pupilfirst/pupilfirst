open CoursesCurriculum__Types;

let str = React.string;

type noticeLink = {
  icon: string,
  title: string,
  href: string,
};

let showNotice =
    (
      ~title,
      ~description,
      ~notice,
      ~link=None,
      ~classes="max-w-3xl mx-auto text-center mt-4 bg-white lg:rounded-lg shadow-md px-6 pt-6 pb-8",
      (),
    ) =>
  <div className=classes>
    <img className="h-50 mx-auto" src={notice |> Notice.icon} />
    <div className="max-w-xl font-bold text-xl mx-auto mt-2 leading-tight">
      {title |> str}
    </div>
    {switch (link) {
     | Some(link) =>
       <a href={link.href} className="mt-4 mb-2 btn btn-primary">
         <FaIcon classes={link.icon} />
         <span className="ml-2"> {link.title |> str} </span>
       </a>
     | None => React.null
     }}
    <div className="text-sm max-w-lg mx-auto mt-2"> {description |> str} </div>
  </div>;

let courseCompletedMessage = course => {
  let csn = course |> Course.certificateSerialNumber;

  let title =
    switch (csn) {
    | Some(_csn) => "Congratulations! You have been issued a certificate."
    | None => "Congratulations! You have completed all milestone targets in this course."
    };

  let description = "You've completed our coursework. Feel free to complete targets that you might have left out, and read up on attached links and resources.";

  let link =
    csn
    |> OptionUtils.map(csn =>
         {
           icon: "fas fa-certificate",
           title: "View Certificate",
           href: "/c/" ++ csn,
         }
       );

  showNotice(~title, ~description, ~link, ~notice=Notice.CourseComplete, ());
};

let courseEndedMessage = () => {
  let title = "Course Ended";
  let description = "The course has ended and submissions are disabled for all targets!";
  showNotice(~title, ~description, ~notice=Notice.CourseEnded, ());
};

let showPreviewMessage = () =>
  <div
    className="flex max-w-lg md:mx-auto mx-3 mt-4 rounded-lg px-3 py-2 shadow-lg items-center border border-primary-300 bg-gray-200 ">
    <img className="w-20 md:w-22 flex-no-shrink" src=Notice.previewModeImage />
    <div className="flex-1 text-left ml-4">
      <h4 className="font-bold text-lg leading-tight">
        {"Preview Mode" |> str}
      </h4>
      <p className="text-sm mt-1">
        {"You are accessing the preview mode for this course" |> str}
      </p>
    </div>
  </div>;

let accessEndedMessage = () => {
  let title = "Access Ended";
  let description = "Your access to this course has ended.";
  showNotice(~title, ~description, ~notice=Notice.AccessEnded, ());
};

let levelUpBlockedMessage = currentLevelNumber => {
  let title = "Review Pending";
  let description =
    "You have submitted all milestone targets in level "
    ++ string_of_int(currentLevelNumber)
    ++ ", but one or more submissions are pending review by a coach. You need to get a passing grade on all milestone targets to level up.";

  showNotice(
    ~title,
    ~description,
    ~notice=Notice.LevelUpBlocked(currentLevelNumber),
    (),
  );
};

let levelUpLimitedMessage = (currentLevelNumber, minimumRequiredLevelNumber) => {
  let title = "Level Up Blocked";
  let currentLevel = currentLevelNumber |> string_of_int;
  let minimumRequiredLevel = minimumRequiredLevelNumber |> string_of_int;
  let description =
    "You're at Level "
    ++ currentLevel
    ++ ", but you have targets in the Level "
    ++ minimumRequiredLevel
    ++ " that are failed, or are pending review by a coach. You'll need to pass all milestone targets in Level "
    ++ minimumRequiredLevel
    ++ " to continue leveling up.";

  showNotice(
    ~title,
    ~description,
    ~notice=
      Notice.LevelUpLimited(currentLevelNumber, minimumRequiredLevelNumber),
    (),
  );
};

let renderLevelUp = course => {
  let title = "Ready to Level Up!";
  let description = "Congratulations! You have successfully completed all milestone targets required to level up. Click the button below to proceed to the next level. New challenges await!";
  <div
    className="max-w-3xl mx-3 lg:mx-auto text-center mt-4 bg-white rounded-lg shadow px-6 pt-4 pb-8">
    {showNotice(~title, ~description, ~notice=Notice.LevelUp, ~classes="", ())}
    <CoursesCurriculum__LevelUpButton course />
  </div>;
};

[@react.component]
let make = (~notice, ~course) => {
  switch (notice) {
  | Notice.Preview => showPreviewMessage()
  | CourseEnded => courseEndedMessage()
  | CourseComplete => courseCompletedMessage(course)
  | AccessEnded => accessEndedMessage()
  | LevelUp => renderLevelUp(course)
  | LevelUpLimited(currentLevelNumber, minimumRequiredLevelNumber) =>
    levelUpLimitedMessage(currentLevelNumber, minimumRequiredLevelNumber)
  | LevelUpBlocked(currentLevelNumber) =>
    levelUpBlockedMessage(currentLevelNumber)
  | Nothing => React.null
  };
};
