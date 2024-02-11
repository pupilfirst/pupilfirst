%%raw(`import "./UserDashboard__Root.css"`)

let t = I18n.t(~scope="components.UsersDashboard__Root")

open UsersDashboard__Types

let str = React.string

type view =
  | ShowCourses
  | ShowCommunities
  | ShowCertificates

let headerSection = (userName, preferredName, userTitle, avatarUrl, showUserEdit, standing) => {
  let name = Belt.Option.getWithDefault(preferredName, userName)

  <div
    className="max-w-5xl mx-auto pt-12 flex flex-col md:flex-row items-start justify-start md:justify-between px-3 lg:px-0 gap-1">
    <div className="flex items-center justify-center gap-2">
      {switch avatarUrl {
      | Some(src) =>
        <img
          className="w-16 h-16 rounded-full border border-gray-300 overflow-hidden shrink-0" src
        />
      | None =>
        <Avatar
          name className="w-16 h-16 border border-gray-300 rounded-full overflow-hidden shrink-0"
        />
      }}
      <div className="text-sm flex flex-col justify-center">
        <div className="text-black font-bold flex items-center justify-start">
          {name->str}
          {ReactUtils.nullUnless(
            <a
              className="hidden md:block ms-2 text-primary-400 font-medium text-xs hover:text-primary-500 rounded-full border px-3 py-1 bg-primary-50 hover:bg-primary-100"
              href="/user/edit">
              <span> {t("edit_profile")->str} </span>
            </a>,
            showUserEdit,
          )}
        </div>
        <div className="text-gray-600 inline-block"> {userTitle->str} </div>
      </div>
    </div>
    {switch standing {
    | Some(standing) =>
      <div
        className="flex flex-row-reverse md:flex-row items-center justify-start md:justify-start gap-2">
        <div className="text-left rtl:text-right rtl:md:text-left md:text-right">
          <p
            style={ReactDOM.Style.make(~color=Standing.color(standing), ())}
            className="font-semibold text-sm">
            {Standing.name(standing)->str}
          </p>
          <a
            href="/user/standing"
            className="text-sm text-primary-500 hover:text-primary-700 hover:underline transition">
            {I18n.ts("view_standing")->str}
          </a>
        </div>
        <div
          id="standing_shield"
          className="w-16 h-16 flex items-center justify-center border border-gray-300 rounded-full">
          <StandingShield color={Standing.color(standing)} sizeClass={"w-12 h-12"} />
        </div>
      </div>
    | None => React.null
    }}
  </div>
}

let navButtonClasses = selected =>
  "font-semibold border-b-2 text-sm py-4 me-6 hover:text-primary-500 hover:border-gray-300 focus:border-gray-300 focus:text-primary-500 focus:outline-none " ++ (
    selected ? "text-primary-500 border-primary-500" : "border-transparent"
  )

let navSection = (view, setView, communities, issuedCertificates) =>
  <div className="border-b mt-6">
    <div role="tablist" className="flex max-w-5xl mx-auto px-3 lg:px-0">
      <button
        role="tab"
        ariaSelected={view == ShowCourses}
        className={navButtonClasses(view == ShowCourses)}
        onClick={_ => setView(_ => ShowCourses)}>
        <i className="fas fa-book text-xs md:text-sm me-2" />
        <span> {t("my_courses")->str} </span>
      </button>
      {ReactUtils.nullUnless(
        <button
          role="tab"
          ariaSelected={view == ShowCommunities}
          className={navButtonClasses(view == ShowCommunities)}
          onClick={_ => setView(_ => ShowCommunities)}>
          <i className="fas fa-users text-xs md:text-sm me-2" />
          <span> {t("communities")->str} </span>
        </button>,
        ArrayUtils.isNotEmpty(communities),
      )}
      {ReactUtils.nullUnless(
        <button
          role="tab"
          ariaSelected={view == ShowCertificates}
          className={navButtonClasses(view == ShowCertificates)}
          onClick={_ => setView(_ => ShowCertificates)}>
          <i className="fas fa-certificate text-xs md:text-sm me-2" />
          <span> {t("certificates")->str} </span>
        </button>,
        ArrayUtils.isNotEmpty(issuedCertificates),
      )}
    </div>
  </div>

let courseLink = (href, title, icon) =>
  <a
    key=href
    href
    className="px-2 py-1 me-2 mt-2 rounded text-sm bg-gray-50 text-gray-500 hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500">
    <i className=icon />
    <span className="font-medium ms-2"> {title->str} </span>
  </a>

let ctaButton = (title, href) =>
  <a
    href
    className="w-full bg-primary-50 mt-4 px-6 py-4 flex text-sm font-semibold justify-between items-center cursor-pointer text-primary-500 hover:bg-primary-100 focus:outline-none focus:bg-primary-100">
    <span>
      <i className="fas fa-book" />
      <span className="ms-2"> {title->str} </span>
    </span>
    <i className="fas fa-arrow-right rtl:rotate-180" />
  </a>

let ctaText = (message, icon) =>
  <div
    className="w-full bg-red-100 text-red-600 mt-4 px-6 py-4 flex text-sm font-semibold justify-center items-center ">
    <span>
      <i className=icon />
      <span className="ms-2"> {message->str} </span>
    </span>
  </div>

let studentLink = (courseId, suffix) => "/courses/" ++ (courseId ++ ("/" ++ suffix))

let callToAction = (course, currentSchoolAdmin) =>
  if currentSchoolAdmin {
    #ViewCourse
  } else if course->Course.author {
    #EditCourse
  } else if course->Course.review {
    #ReviewSubmissions
  } else if course->Course.exited {
    #DroppedOut
  } else if course->Course.ended {
    #CourseEnded
  } else if course->Course.accessEnded {
    #AccessEnded
  } else {
    #ViewCourse
  }

let ctaFooter = (course, currentSchoolAdmin) => {
  let courseId = Course.id(course)

  switch callToAction(course, currentSchoolAdmin) {
  | #ViewCourse => ctaButton(t("cta.view_course"), studentLink(courseId, "curriculum"))
  | #EditCourse =>
    ctaButton(t("cta.edit_curriculum"), "/school/courses/" ++ (courseId ++ "/curriculum"))
  | #ReviewSubmissions => ctaButton(t("cta.review_submissions"), studentLink(courseId, "review"))
  | #DroppedOut => ctaText(t("cta.dropped_out"), "fas fa-user-slash")
  | #AccessEnded => ctaText(t("cta.access_ended"), "fas fa-history")
  | #CourseEnded => ctaText(t("cta.course_ended"), "fas fa-history")
  }
}

let communityLinks = (communityIds, communities) => Js.Array.map(id => {
    let community = Js.Array.find(c => Community.id(c) == id, communities)
    switch community {
    | Some(c) =>
      <a
        key={Community.id(c)}
        href={Community.path(c)}
        className="px-2 py-1 me-2 mt-2 rounded text-sm bg-gray-50 text-gray-500 hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500">
        <i className="fas fa-users" />
        <span className="font-medium ms-2"> {Community.name(c)->str} </span>
      </a>
    | None => React.null
    }
  }, communityIds)->React.array

let courseLinks = (course, currentSchoolAdmin, communities) => {
  let courseId = Course.id(course)
  let cta = callToAction(course, currentSchoolAdmin)

  <div className="flex flex-wrap px-4 mt-2">
    {ReactUtils.nullUnless(
      courseLink(
        "/school/courses/" ++ (courseId ++ "/curriculum"),
        t("cta.edit_curriculum"),
        "fas fa-check-square",
      ),
      Course.author(course) && cta != #EditCourse,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "curriculum"), t("cta.view_curriculum"), "fas fa-book"),
      cta != #ViewCourse,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "leaderboard"), t("cta.leaderboard"), "fas fa-calendar-alt"),
      Course.enableLeaderboard(course),
    )}
    {ReactUtils.nullUnless(
      courseLink(
        studentLink(courseId, "review"),
        t("cta.review_submissions"),
        "fas fa-check-square",
      ),
      Course.review(course) && cta != #ReviewSubmissions,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "cohorts"), t("cta.my_cohorts"), "fas fa-user-friends"),
      Course.review(course),
    )}
    {communityLinks(Course.linkedCommunities(course), communities)}
  </div>
}

let coursesSection = (courses, communities, currentSchoolAdmin) =>
  <div className="w-full max-w-5xl mx-auto">
    {ReactUtils.nullUnless(
      <div
        className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center mt-4">
        <FaIcon classes="fas fa-book text-5xl text-gray-400" />
        <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
          {t("empty_courses")->str}
        </h4>
      </div>,
      ArrayUtils.isEmpty(courses),
    )}
    <div className="flex flex-wrap flex-1 lg:-mx-5"> {Js.Array.map(course =>
        <div
          key={course->Course.id}
          ariaLabel={course->Course.name}
          className="w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
          <div
            key={course->Course.id}
            className="overflow-hidden shadow bg-white rounded-lg flex flex-col justify-between h-full">
            <div>
              <div className="relative">
                <div className="relative pb-1/2 bg-gray-800">
                  {switch course->Course.thumbnailUrl {
                  | Some(url) => <img className="absolute h-full w-full object-cover" src=url />
                  | None =>
                    <div
                      className="user-dashboard-course__cover absolute h-full w-full svg-bg-pattern-1"
                    />
                  }}
                </div>
              </div>
              <div className="flex gap-2 border-b border-gray-200" key={course->Course.id}>
                <div className="block h-min ms-6 pt-3 pb-2 px-2 bg-primary-100 rounded-b-full">
                  <PfIcon className="if i-book-solid if-fw text-primary-400" />
                </div>
                <h4
                  className="w-full text-black font-semibold leading-tight pe-6 py-3 text-lg md:text-xl">
                  {Course.name(course)->str}
                </h4>
              </div>
              <div
                className="user-dashboard-course__description text-sm px-6 pt-3 w-full leading-relaxed">
                {Course.description(course)->str}
              </div>
              {if course->Course.exited && (!(course->Course.review) && !(course->Course.author)) {
                <div className="text-sm py-4 bg-red-100 rounded mt-2 px-6">
                  {t("course_locked_message")->str}
                </div>
              } else {
                <div> {courseLinks(course, currentSchoolAdmin, communities)} </div>
              }}
            </div>
            <div> {ctaFooter(course, currentSchoolAdmin)} </div>
          </div>
        </div>
      , courses)->React.array} </div>
  </div>

let communitiesSection = communities =>
  <div className="w-full max-w-5xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5"> {Js.Array.map(community =>
        <div
          key={community->Community.id} className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
          <a
            className="w-full h-full bg-white border border-gray-300 rounded-lg overflow-hidden"
            href={Community.path(community)}>
            <div
              className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4"
            />
            <div className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
              <h4 className="font-bold text-sm pt-2 leading-tight">
                {Community.name(community)->str}
              </h4>
              <div className="btn btn-small btn-primary-ghost mt-2">
                {t("cta.visit_community")->str}
              </div>
            </div>
          </a>
        </div>
      , communities)->React.array} </div>
  </div>

let certificatesSection = issuedCertificates =>
  <div className="w-full max-w-5xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5"> {Js.Array.map(issuedCertificate =>
        <div
          key={issuedCertificate->IssuedCertificate.id}
          className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
          <a
            className="w-full h-full bg-white border border-gray-300 rounded-lg overflow-hidden"
            href={"/c/" ++ issuedCertificate->IssuedCertificate.serialNumber}>
            <div
              className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4"
            />
            <div className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
              <div>
                <h4 className="font-bold text-sm pt-2 leading-tight">
                  {IssuedCertificate.courseName(issuedCertificate)->str}
                </h4>
                <div className="text-xs">
                  <span> {t("issued_on")->str} </span>
                  <span className="ms-1">
                    {issuedCertificate
                    ->IssuedCertificate.createdAt
                    ->DateFns.formatPreset(~short=true, ~year=true, ())
                    ->str}
                  </span>
                </div>
              </div>
              <div className="btn btn-small btn-primary-ghost mt-2">
                {t("cta.view_certificate")->str}
              </div>
            </div>
          </a>
        </div>
      , issuedCertificates)->React.array} </div>
  </div>

@react.component
let make = (
  ~currentSchoolAdmin,
  ~courses,
  ~communities,
  ~showUserEdit,
  ~userName,
  ~preferredName,
  ~userTitle,
  ~avatarUrl,
  ~issuedCertificates,
  ~standing,
) => {
  let (view, setView) = React.useState(() => ShowCourses)
  <div className="bg-gray-50 h-full">
    <div className="bg-white">
      {headerSection(userName, preferredName, userTitle, avatarUrl, showUserEdit, standing)}
      {navSection(view, setView, communities, issuedCertificates)}
    </div>
    <div className="pb-8">
      {switch view {
      | ShowCourses => coursesSection(courses, communities, currentSchoolAdmin)
      | ShowCommunities => communitiesSection(communities)
      | ShowCertificates => certificatesSection(issuedCertificates)
      }}
    </div>
  </div>
}
