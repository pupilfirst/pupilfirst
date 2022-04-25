%bs.raw(`require("courses/shared/background_patterns.css")`)
%bs.raw(`require("./UserDashboard__Root.css")`)

let t = I18n.t(~scope="components.UsersDashboard__Root")

open UsersDashboard__Types

let str = React.string

type view =
  | ShowCourses
  | ShowCommunities
  | ShowCertificates

let headerSectiom = (userName, userTitle, avatarUrl, showUserEdit) =>
  <div className="max-w-4xl mx-auto pt-12 flex items-center justify-between px-3 lg:px-0">
    <div className="flex">
      {switch avatarUrl {
      | Some(src) =>
        <img
          className="w-16 h-16 rounded-full border object-cover border-gray-400 overflow-hidden flex-shrink-0 mr-4"
          src
        />
      | None =>
        <Avatar
          name=userName
          className="w-16 h-16 mr-4 border border-gray-400 rounded-full overflow-hidden flex-shrink-0"
        />
      }}
      <div className="text-sm flex flex-col justify-center">
        <div className="text-black font-bold inline-block"> {userName->str} </div>
        <div className="text-gray-600 inline-block"> {userTitle->str} </div>
      </div>
    </div>
    {ReactUtils.nullUnless(
      <a className="btn" href="/user/edit">
        <i className="fas fa-edit text-xs md:text-sm mr-2" />
        <span> {t("edit_profile")->str} </span>
      </a>,
      showUserEdit,
    )}
  </div>

let navButtonClasses = selected =>
  "font-semibold border-b-2 text-sm py-4 mr-6 hover:text-primary-500 hover:border-gray-300 focus:border-gray-300 focus:text-primary-500 focus:outline-none " ++ (
    selected ? "text-primary-500 border-primary-500" : "border-transparent"
  )

let navSection = (view, setView, communities, issuedCertificates) =>
  <div className="border-b mt-6">
    <div role="tablist" className="flex max-w-4xl mx-auto px-3 lg:px-0">
      <button
        role="tab"
        ariaSelected={view == ShowCourses}
        className={navButtonClasses(view == ShowCourses)} onClick={_ => setView(_ => ShowCourses)}>
        <i className="fas fa-book text-xs md:text-sm mr-2" /> <span> {t("my_courses")->str} </span>
      </button>
      {ReactUtils.nullUnless(
        <button
          role="tab"
          ariaSelected={view == ShowCommunities}
          className={navButtonClasses(view == ShowCommunities)}
          onClick={_ => setView(_ => ShowCommunities)}>
          <i className="fas fa-users text-xs md:text-sm mr-2" />
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
          <i className="fas fa-certificate text-xs md:text-sm mr-2" />
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
    className="px-2 py-1 mr-2 mt-2 rounded text-sm bg-gray-100 text-gray-800 hover:bg-gray-200 hover:text-primary-500 focus:outline-none focus:bg-gray-200 focus:text-primary-500">
    <i className=icon /> <span className="font-semibold ml-2"> {title->str} </span>
  </a>

let ctaButton = (title, href) =>
  <a
    href
    className="w-full bg-gray-200 mt-4 px-6 py-4 flex text-sm font-semibold justify-between items-center cursor-pointer text-primary-500 hover:bg-gray-300 focus:outline-none focus:bg-gray-300">
    <span> <i className="fas fa-book" /> <span className="ml-2"> {title->str} </span> </span>
    <i className="fas fa-arrow-right" />
  </a>

let ctaText = (message, icon) =>
  <div
    className="w-full bg-red-100 text-red-600 mt-4 px-6 py-4 flex text-sm font-semibold justify-center items-center ">
    <span> <i className=icon /> <span className="ml-2"> {message->str} </span> </span>
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
        className="px-2 py-1 mr-2 mt-2 rounded text-sm bg-gray-100 text-gray-800 hover:bg-gray-200 hover:text-primary-500 focus:outline-none focus:bg-gray-200 focus:text-primary-500">
        <i className="fas fa-users" />
        <span className="font-semibold ml-2"> {Community.name(c)->str} </span>
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
        "Edit Curriculum",
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
      courseLink(studentLink(courseId, "students"), t("cta.my_students"), "fas fa-user-friends"),
      Course.review(course),
    )}
    {communityLinks(Course.linkedCommunities(course), communities)}
  </div>
}

let coursesSection = (courses, communities, currentSchoolAdmin) =>
  <div className="w-full max-w-4xl mx-auto">
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
            className="flex overflow-hidden shadow bg-white rounded-lg flex flex-col justify-between h-full">
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
                <div
                  className="user-dashboard-course__title-container absolute w-full flex items-center h-16 bottom-0 z-50"
                  key={course->Course.id}>
                  <h4
                    className="user-dashboard-course__title text-white font-semibold leading-tight pl-6 pr-4 text-lg md:text-xl">
                    {Course.name(course)->str}
                  </h4>
                </div>
              </div>
              <div
                className="user-dashboard-course__description text-sm px-6 pt-4 w-full leading-relaxed">
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
  <div className="w-full max-w-4xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5">
      {Js.Array.map(
        community =>
          <div
            key={community->Community.id}
            className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
            <a
              className="w-full h-full shadow rounded-lg hover:shadow-lg"
              href={Community.path(community)}>
              <div
                className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4 shadow rounded-t-lg"
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
          </div>,
        communities,
      )->React.array}
    </div>
  </div>

let certificatesSection = issuedCertificates =>
  <div className="w-full max-w-4xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5">
      {Js.Array.map(
        issuedCertificate =>
          <div
            key={issuedCertificate->IssuedCertificate.id}
            className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
            <a
              className="w-full h-full shadow rounded-lg hover:shadow-lg"
              href={"/c/" ++ issuedCertificate->IssuedCertificate.serialNumber}>
              <div
                className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4 shadow rounded-t-lg"
              />
              <div className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
                <div>
                  <h4 className="font-bold text-sm pt-2 leading-tight">
                    {IssuedCertificate.courseName(issuedCertificate)->str}
                  </h4>
                  <div className="text-xs">
                    <span> {"Issued on:"->str} </span>
                    <span className="ml-1">
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
          </div>,
        issuedCertificates,
      )->React.array}
    </div>
  </div>

@react.component
let make = (
  ~currentSchoolAdmin,
  ~courses,
  ~communities,
  ~showUserEdit,
  ~userName,
  ~userTitle,
  ~avatarUrl,
  ~issuedCertificates,
) => {
  let (view, setView) = React.useState(() => ShowCourses)
  <div className="bg-gray-100">
    <div className="bg-white">
      {headerSectiom(userName, userTitle, avatarUrl, showUserEdit)}
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
