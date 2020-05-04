[%bs.raw {|require("./CoursesReport.css")|}];
open CoursesReport__Types;

let str = React.string;

type selectedTab = [ | `Overview | `Progress];

type targetStatus = [ | `Pending | `Failed | `Submitted | `Passed];

type filter = {
  level: option(Level.t),
  targetStatus,
};

type state = {
  selectedTab,
  filter,
  overviewData: OverviewData.t,
};

type action =
  | SelectOverviewTab
  | SelectProgressTab
  | SaveOverviewData(OverviewData.t);

let buttonClasses = selected =>
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none "
  ++ (
    selected
      ? "bg-primary-100 shadow-inner text-primary-500"
      : "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
  );

let reducer = (state, action) => {
  switch (action) {
  | SelectOverviewTab => {...state, selectedTab: `Overview}
  | SelectProgressTab => {...state, selectedTab: `Progress}
  | SaveOverviewData(overviewData) => {...state, overviewData}
  };
};

module StudentReportOverviewQuery = [%graphql
  {|
    query StudentReportOverviewQuery($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        evaluationCriteria {
          id, name, maxGrade, passGrade
        },
        team {
          id
          name
          levelId
          droppedOutAt
          accessEndsAt
          students {
            id
            name
            title
            avatarUrl
          }
          coachUserIds
        }
        totalTargets
        targetsCompleted
        completedLevelIds
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
      }
    }
  |}
];

let saveOverviewData = (studentId, send, data) => {
  send(
    SaveOverviewData(Loaded(data |> StudentOverview.makeFromJs(studentId))),
  );
};

let getOverviewData = (studentId, send, ()) => {
  StudentReportOverviewQuery.make(~studentId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##studentDetails |> saveOverviewData(studentId, send);
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {Js.Promise.resolve()})
  |> ignore;

  None;
};

[@react.component]
let make = (~studentId, ~levels, ~coaches) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        selectedTab: `Overview,
        filter: {
          level: None,
          targetStatus: `Passed,
        },
        overviewData: Unloaded,
      },
    );

  React.useEffect1(getOverviewData(studentId, send), [|studentId|]);

  <div
    className="bg-gray-100 pt-9 pb-8 px-3 -mt-7 border border-transparent shadow rounded-lg">
    <div className="bg-gray-100 static">
      <div className="max-w-3xl mx-auto">
        <div
          className="flex flex-col md:flex-row items-end lg:items-center py-4">
          <div
            ariaLabel="status-tab"
            className="course-report__category-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(state.selectedTab == `Overview)}
              onClick={_ => send(SelectOverviewTab)}>
              {"Overview" |> str}
            </button>
            <button
              className={buttonClasses(state.selectedTab == `Progress)}
              onClick={_ => send(SelectProgressTab)}>
              {"Progress" |> str}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div className="max-w-3xl mx-auto border border-transparent shadow rounded-lg">
      {switch (state.selectedTab) {
       | `Overview =>
         <CoursesReport__Overview
           overviewData={state.overviewData}
           levels
           coaches
         />
       | `Progress => React.null
       }}
    </div>
  </div>;
};
