[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];

open CoursesStudents__Types;

type state = {submissions: Submissions.t};

let str = React.string;

module StudentSubmissionsQuery = [%graphql
  {|
   query($studentId: ID!, $after: String) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 ) {
       nodes {
         id
        createdAt
        levelId
        passedAt
        title
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   |}
];

let updateStudentSubmissions =
    (setState, endCursor, hasNextPage, submissions, nodes) => {
  let updatedSubmissions =
    (
      switch (nodes) {
      | None => [||]
      | Some(submissionsArray) => submissionsArray |> Submission.makeFromJs
      }
    )
    |> Array.to_list
    |> List.flatten
    |> Array.of_list
    |> Array.append(submissions);
  setState(state =>
    {
      submissions:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(updatedSubmissions)
        | (true, Some(cursor)) =>
          PartiallyLoaded(updatedSubmissions, cursor)
        },
    }
  );
};

let getStudentSubmissions =
    (authenticityToken, studentId, cursor, setState, submissions) => {
  (
    switch (cursor) {
    | Some(cursor) =>
      StudentSubmissionsQuery.make(~studentId, ~after=cursor, ())
    | None => StudentSubmissionsQuery.make(~studentId, ())
    }
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##studentSubmissions##nodes
       |> updateStudentSubmissions(
            setState,
            response##studentSubmissions##pageInfo##endCursor,
            response##studentSubmissions##pageInfo##hasNextPage,
            submissions,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~studentId, ~levels) => {
  let (state, setState) = React.useState(() => {submissions: Unloaded});
  React.useEffect1(
    () => {
      getStudentSubmissions(
        AuthenticityToken.fromHead(),
        studentId,
        None,
        setState,
        [||],
      );
      None;
    },
    [|studentId|],
  );
  <div />;
};
