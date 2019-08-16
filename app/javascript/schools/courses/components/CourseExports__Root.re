[@bs.config {jsx: 3}];

open CourseExports__Types;

let str = React.string;

let readinessString = courseExport =>
  switch (courseExport |> CourseExport.file) {
  | None =>
    let timeDistance =
      courseExport
      |> CourseExport.createdAt
      |> DateFns.parseString
      |> DateFns.distanceInWordsToNow(~addSuffix=true);
    "Requested " ++ timeDistance;
  | Some(file) =>
    let timeDistance =
      file
      |> CourseExport.fileCreatedAt
      |> DateFns.parseString
      |> DateFns.distanceInWordsToNow(~addSuffix=true);
    "Prepared " ++ timeDistance;
  };

[@react.component]
let make = (~course, ~exports, ~tags) => {
  let (formVisible, setFormVisible) = React.useState(() => false);

  <div
    key="School admin coaches course index"
    className="flex flex-1 h-screen overflow-y-scroll">
    {
      switch (formVisible) {
      | false => ReasonReact.null
      | true =>
        <div>
          {"Editor drawer should be open with options for exporting" |> str}
        </div>
      }
    }
    <div className="flex-1 flex flex-col bg-gray-100">
      /* <div className="flex px-6 py-2 items-center justify-between">
           <button
             onClick={
               event => {
                 ReactEvent.Mouse.preventDefault(event);
                 setFormVisible(_ => true);
               }
             }
             className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-20 cursor-pointer">
             <i className="fas fa-user-plus text-lg" />
             <h5 className="font-semibold ml-2">
               {"Create a new export" |> str}
             </h5>
           </button>
         </div> */

        {
          switch (exports) {
          | [||] =>
            <div
              className="flex justify-center bg-gray-100 border rounded p-3 italic mx-auto max-w-2xl w-full mt-4">
              {"You haven't exported anything yet!" |> str}
            </div>
          | exports =>
            <div className="px-6 pb-4 mt-5 flex flex-1 bg-gray-100">
              <div className="max-w-2xl w-full mx-auto relative">
                <h4 className="mt-5 w-full"> {"Exports" |> str} </h4>
                <div className="flex mt-4 -mx-3 items-start flex-wrap">
                  {
                    exports
                    |> ArrayUtils.copyAndSort((x, y) =>
                         (y |> CourseExport.createdAt |> Js.Date.parseAsFloat)
                         -. (
                           x |> CourseExport.createdAt |> Js.Date.parseAsFloat
                         )
                         |> int_of_float
                       )
                    |> Array.map(courseExport =>
                         <div
                           key={courseExport |> CourseExport.id}
                           className="flex w-1/2 items-center mb-4 px-3">
                           <div
                             className="course-faculty__list-item shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                             <div className="flex flex-1 justify-between">
                               <div className="pt-4 pb-3 px-4">
                                 <div className="text-sm">
                                   <p className="text-black font-semibold">
                                     {"Submissions" |> str}
                                   </p>
                                   <p
                                     className="text-gray-600 font-semibold text-xs mt-px">
                                     {courseExport |> readinessString |> str}
                                   </p>
                                 </div>
                                 {
                                   switch (courseExport |> CourseExport.tags) {
                                   | [||] => ReasonReact.null
                                   | tags =>
                                     <div
                                       className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                                       {
                                         tags
                                         |> Array.map(tag =>
                                              <span
                                                key=tag
                                                className="px-2 py-1 border rounded bg-primary-100 text-primary-600 mt-1 mr-1">
                                                {tag |> str}
                                              </span>
                                            )
                                         |> React.array
                                       }
                                     </div>
                                   }
                                 }
                               </div>
                               {
                                 switch (courseExport |> CourseExport.file) {
                                 | None => ReasonReact.null
                                 | Some(file) =>
                                   <a
                                     ariaLabel={
                                       "Download Course Export "
                                       ++ (courseExport |> CourseExport.id)
                                     }
                                     className="w-10 text-xs text-sm course-faculty__list-item-remove text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                     href={file |> CourseExport.filePath}>
                                     <FaIcon classes="fas fa-file-download" />
                                   </a>
                                 }
                               }
                             </div>
                           </div>
                         </div>
                       )
                    |> React.array
                  }
                </div>
              </div>
            </div>
          }
        }
      </div>
  </div>;
};
