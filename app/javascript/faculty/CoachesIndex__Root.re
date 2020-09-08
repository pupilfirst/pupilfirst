let str = React.string;

module Coach = CoachesIndex__Coach;

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
      <div className="block flex-1">
        <a
          href="#"
          className="block w-full px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
          {str("About")}
        </a>
      </div>
      {switch (Coach.connectLink(coach)) {
       | Some(href) =>
         <div className="flex-1">
           <a
             href
             target="_blank"
             className="block flex-1 px-3 py-2 text-center text-sm font-semibold hover:bg-gray-200 hover:text-primary-500">
             {str("Connect")}
           </a>
         </div>
       | None => React.null
       }}
    </div>
  </div>;
};

[@react.component]
let make = (~subheading, ~coaches, ~studentInCourseIds) => {
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
  </div>;
};
