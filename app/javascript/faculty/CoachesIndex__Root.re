[%bs.raw {|require("./CoachesIndex__Root.css")|}];

let str = React.string;

module Coach = CoachesIndex__Coach;

let connectLink = href =>
  <a
    href
    target="_blank"
    className="block flex-1 px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
    {str("Connect")}
  </a>;

let overlay = (coach, about) => {
  <div className="fixed z-30 inset-0 overflow-y-auto">
    <div
      className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div className="fixed inset-0">
        <div className="absolute inset-0 bg-gray-900 opacity-75" />
      </div>
      // This element centers the modal contents.
      <span className="hidden sm:inline-block sm:align-middle sm:h-screen" />
      <div
        className="inline-block relative bg-white rounded-lg shadow-lg align-bottom mt-16 sm:mb-8  sm:align-middle sm:max-w-lg sm:w-full"
        role="dialog"
        ariaModal=true
        ariaLabelledby="modal-headline">
        <div className="block absolute top-0 left-0 -mt-12">
          <Link
            href="/coaches"
            className="flex justify-center items-center bg-gray-900 rounded-full p-2 w-10 h-10 text-gray-400 hover:opacity-75 hover:text-gray-500 focus:outline-none focus:text-gray-500 transition ease-in-out duration-150"
            ariaLabel="Close">
            <PfIcon className="if i-times-regular if-fw text-2xl" />
          </Link>
        </div>
        <div className="pb-5">
          <div
            className="faculty-card__avatar-container bg-gray-200 px-2 py-10 rounded-t-lg">
            {switch (Coach.avatarUrl(coach)) {
             | Some(src) =>
               <img
                 src
                 className="mx-auto w-40 h-40 -mb-18 border-4 border-gray-400 rounded-full object-cover"
                 alt={"Avatar of " ++ Coach.name(coach)}
               />
             | None =>
               <Avatar
                 name={Coach.name(coach)}
                 className="mx-auto w-40 h-40 -mb-18 border-4 border-gray-400 rounded-full object-cover"
               />
             }}
          </div>
          <div className="py-3 mt-8">
            <p className="text-sm text-center font-semibold">
              {Coach.name(coach)->str}
            </p>
            <p className="text-center text-xs text-gray-800 pt-1">
              {Coach.fullTitle(coach)->str}
            </p>
          </div>
          <p className="text-center text-sm px-6"> {str(about)} </p>
          {switch (Coach.connectLink(coach)) {
           | Some(href) =>
             <div className="mt-3 text-center px-4 pb-4 sm:px-6 sm:pb-6">
               <div
                 className="inline-flex overflow-hidden border rounded border-primary-500 text-primary-500">
                 {connectLink(href)}
               </div>
             </div>
           | None => React.null
           }}
        </div>
      </div>
    </div>
  </div>;
};

let card = coach => {
  <div
    key={Coach.id(coach)}
    className="flex flex-col justify-between bg-white rounded-lg shadow-md pt-8">
    <div className="px-6">
      {switch (Coach.avatarUrl(coach)) {
       | Some(src) =>
         <img
           src
           className="mx-auto w-40 h-40 border-4 border-gray-200 rounded-full object-cover"
           alt="Coach's Avatar"
         />
       | None =>
         <Avatar
           name={Coach.name(coach)}
           className="mx-auto w-40 h-40 border-4 border-gray-200 rounded-full object-cover"
         />
       }}
      <div className="py-3">
        <p className="text-sm text-center font-semibold">
          {Coach.name(coach)->str}
        </p>
        <p className="text-center text-xs text-gray-800 pt-1">
          {Coach.fullTitle(coach)->str}
        </p>
      </div>
    </div>
    <div
      className="flex justify-between divide-x border-t divide-gray-400 border-gray-400 rounded-b-lg overflow-hidden">
      {switch (Coach.about(coach)) {
       | Some(_about) =>
         <div className="block flex-1">
           <Link
             href={
               "/coaches/"
               ++ Coach.id(coach)
               ++ "/"
               ++ Coach.name(coach)->StringUtils.parameterize
             }
             className="block w-full px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
             {str("About")}
           </Link>
         </div>
       | None => React.null
       }}
      {switch (Coach.connectLink(coach)) {
       | Some(href) => <div className="flex-1"> {connectLink(href)} </div>
       | None => React.null
       }}
    </div>
  </div>;
};

[@react.component]
let make = (~subheading, ~coaches, ~studentInCourseIds) => {
  let url = ReasonReactRouter.useUrl();

  let selectedCoachOverlay =
    switch (url.path) {
    | ["coaches", coachIdParam, ..._] =>
      coachIdParam
      ->StringUtils.paramToId
      ->Belt.Option.flatMap(coachId => {
          coaches |> Js.Array.find(coach => Coach.id(coach) == coachId)
        })
      ->Belt.Option.mapWithDefault(React.null, coach =>
          switch (Coach.about(coach)) {
          | Some(about) => overlay(coach, about)
          | None => React.null
          }
        )
    | _otherPaths => React.null
    };

  <div>
    selectedCoachOverlay
    <div className="max-w-5xl mx-auto px-4">
      <h1 className="text-4xl text-center mt-3"> {str("Coaches")} </h1>
      <div>
        {switch (subheading) {
         | Some(subheading) =>
           <p className="text-center"> {str(subheading)} </p>
         | None => React.null
         }}
        <div
          className="grid sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5 py-8">
          {Js.Array.map(card, coaches)->React.array}
        </div>
      </div>
    </div>
  </div>;
};
