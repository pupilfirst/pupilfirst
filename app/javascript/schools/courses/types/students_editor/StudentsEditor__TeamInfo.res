module StudentInfo = StudentsEditor__StudentInfo

type rec t = {
  nature: nature,
  tags: Belt.Set.String.t,
}
and nature =
  | SingleMember(StudentInfo.t)
  | MultiMember(string, array<StudentInfo.t>)

let name = t =>
  switch t.nature {
  | SingleMember(_) => ""
  | MultiMember(name, _) => name
  }

let tags = t => t.tags |> Belt.Set.String.toArray

let nature = t => t.nature

let students = t =>
  switch t.nature {
  | SingleMember(studentInfo) => [studentInfo]
  | MultiMember(_, students) => students
  }

let toJsArray = t =>
  students(t) |> Js.Array.map(
    StudentInfo.toJsObject(~teamName=name(t), ~tags=Belt.Set.String.toArray(t.tags)),
  )

let make = (~name, ~tags, ~students) =>
  if Js.Array.length(students) > 1 {
    {
      nature: MultiMember(name, students),
      tags: tags,
    }
  } else {
    {
      nature: SingleMember(Js.Array.unsafe_get(students, 0)),
      tags: tags,
    }
  }

let addStudentToArray = (ts, studentInfo, teamName, tags) =>
  switch teamName {
  | Some(teamName) =>
    // A reference is being used to allow the scan & modification of the teamInfo array to finish in one pass.
    let teamFoundAndUpdated = ref(false)

    let teams = ts |> Js.Array.map(t =>
      switch t.nature {
      | SingleMember(_) => t
      | MultiMember(name, students) =>
        if name == teamName {
          teamFoundAndUpdated := true
          let newStudents = students |> Js.Array.concat([studentInfo])
          {
            tags: Belt.Set.String.union(t.tags, Belt.Set.String.fromArray(tags)),
            nature: MultiMember(name, newStudents),
          }
        } else {
          t
        }
      }
    )

    \"!"(teamFoundAndUpdated)
      ? teams
      : ts |> Js.Array.concat([
          {
            nature: MultiMember(teamName, [studentInfo]),
            tags: Belt.Set.String.fromArray(tags),
          },
        ])

  | None =>
    ts |> Js.Array.concat([
      {
        nature: SingleMember(studentInfo),
        tags: Belt.Set.String.fromArray(tags),
      },
    ])
  }

let compareStudents = (checkedStudent, requestedStudent, removedFromArray) =>
  if StudentInfo.email(checkedStudent) != StudentInfo.email(requestedStudent) {
    true
  } else {
    removedFromArray := true
    false
  }

let removeStudentFromArray = (ts, studentInfo) => {
  // This ref is used to avoid unnecessary second pass if single-member team is filtered out.
  let removedFromArray = ref(false)

  let teams = ts |> Js.Array.filter(t =>
    switch t.nature {
    | SingleMember(student) => compareStudents(student, studentInfo, removedFromArray)
    | MultiMember(_, students) =>
      if students |> Js.Array.length == 1 {
        Js.Array.unsafe_get(students, 0)->compareStudents(studentInfo, removedFromArray)
      } else {
        true
      }
    }
  )

  \"!"(removedFromArray) ? teams : teams |> Js.Array.map(t =>
        switch t.nature {
        | SingleMember(_) => t
        | MultiMember(name, students) =>
          let filteredStudents =
            students |> Js.Array.filter(student =>
              StudentInfo.email(student) != StudentInfo.email(studentInfo)
            )
          {...t, nature: MultiMember(name, filteredStudents)}
        }
      )
}

let tagsFromArray = ts =>
  (ts |> Js.Array.reduce(
    (tags, team) => Belt.Set.String.union(tags, team.tags),
    Belt.Set.String.empty,
  ))->Belt.Set.String.toArray

let studentEmailsFromArray = ts => ts |> Js.Array.map(t =>
    switch t.nature {
    | SingleMember(studentInfo) => [StudentInfo.email(studentInfo)]
    | MultiMember(_, students) => Js.Array.map(StudentInfo.email, students)
    }
  ) |> ArrayUtils.flattenV2
