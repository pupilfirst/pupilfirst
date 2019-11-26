[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;

type state = {submissions: array(Submission.t)};

let str = React.string;

module StudentSubmissionsQuery = [%graphql
  {|
   query($studentId: ID!, $after: String!) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 ) {
       nodes {
         id
        createdAt
        grades {
          grade
          evaluationCriterionId
        }
        levelId
        passedAt
        title
       }
      }
    }
   |}
];

[@react.component]
let make = (~studentId, ~levels) => {
  <div />;
};
