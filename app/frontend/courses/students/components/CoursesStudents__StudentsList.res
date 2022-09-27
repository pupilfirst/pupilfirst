%%raw(`import "./CoursesStudents__Root.css"`)
let t = I18n.t(~scope="components.CoursesStudents__StudentsList")
let ts = I18n.t(~scope="shared")

open CoursesStudents__Types

let str = React.string

let levelInfo = level =>
  <span
    className="inline-flex flex-col items-center rounded bg-orange-100 border border-orange-300 px-2 pt-2 pb-1">
    <p className="text-xs font-semibold"> {ts("level") |> str} </p>
    <p className="font-bold"> {level->Shared__Level.number |> string_of_int |> str} </p>
  </span>

let userTags = student => {
  let tags = UserDetails.taggings(StudentInfo.user(student))
  tags->ArrayUtils.isNotEmpty
    ? <div className="hidden md:flex flex-wrap">
        {tags
        |> Js.Array.map(tag =>
          <div
            className="bg-blue-100 mt-1 mr-1 py-px px-2 text-tiny rounded-lg font-semibold text-gray-900
            "
            key={tag}>
            {str(tag)}
          </div>
        )
        |> React.array}
      </div>
    : React.null
}

let studentTags = student => {
  StudentInfo.taggings(student) |> ArrayUtils.isNotEmpty
    ? <div className="hidden md:flex flex-wrap">
        {StudentInfo.taggings(student)
        |> Js.Array.map(tag =>
          <div
            className="bg-gray-100 rounded-lg font-semibold mt-1 mr-1 py-px px-2 text-tiny text-gray-900"
            key={tag}>
            {str(tag)}
          </div>
        )
        |> React.array}
      </div>
    : React.null
}

let showStudent = student => {
  <Link
    props={"data-student-id": student->StudentInfo.id}
    href={"/students/" ++ (student->StudentInfo.id ++ "/report")}
    key={student->StudentInfo.id}
    ariaLabel={"Student " ++ student->StudentInfo.user->UserDetails.name}
    className="flex md:flex-row justify-between bg-white mt-4 rounded-lg shadow cursor-pointer hover:border-primary-500 hover:text-primary-500 hover:shadow-md focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-focusColor-500">
    <div className="flex flex-col justify-center md:flex-row ">
      <div className="flex w-full items-start md:items-center p-3 md:px-4 md:py-5">
        {CoursesStudents__PersonalCoaches.avatar(
          student->StudentInfo.user->UserDetails.avatarUrl,
          student->StudentInfo.user->UserDetails.name,
        )}
        <div className="ml-2 md:ml-3 block text-sm md:pr-2">
          <p className="font-semibold inline-block leading-snug">
            {student->StudentInfo.user->UserDetails.name->str}
          </p>
          <div
            className="py-px text-gray-600 text-xs leading-snug flex flex-col sm:flex-row sm:items-center">
            <span className="font-semibold pr-2">
              {student->StudentInfo.user->UserDetails.fullTitle->str}
            </span>
            <span className="sm:pl-2 sm:border-l border-gray-400 italic">
              {switch student->StudentInfo.user->UserDetails.lastSeenAt {
              | Some(date) =>
                t(
                  ~variables=[
                    ("time_string", date->DateFns.formatDistanceToNowStrict(~addSuffix=true, ())),
                  ],
                  "last_seen",
                )->str
              | None => t("no_last_seen")->str
              }}
            </span>
          </div>
          <div className="text-gray-600 font-semibold text-xs leading-snug flex items-start">
            {userTags(student)} {studentTags(student)}
          </div>
        </div>
      </div>
    </div>
    <div
      ariaLabel={"student level info:" ++ student->StudentInfo.id}
      className="flex items-center gap-6 justify-end md:justify-between p-3 md:p-4">
      <CoursesStudents__PersonalCoaches
        title={<div className="mb-1 font-semibold text-gray-800 text-tiny uppercase">
          {t("personal_coaches") -> str}
        </div>}
        className="hidden md:inline-block"
        coaches={StudentInfo.personalCoaches(student)}
      />
      {levelInfo(student->StudentInfo.level)}
    </div>
  </Link>
}

@react.component
let make = (~students) =>
  <div>
    {  ArrayUtils.isEmpty(students)
      ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
          <h4 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
            {t("no_students") -> str}
          </h4>
        </div>
      : students->Js.Array2.map(showStudent)->React.array}
  </div>
