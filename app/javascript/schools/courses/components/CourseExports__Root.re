[@bs.config {jsx: 3}];

open CourseExports__Types;

let str = React.string;

type state = {
  visible: bool,
  tagsSelection: array((Tag.id, string, bool)),
  saving: bool,
  reviewedOnly: bool,
};

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

let updateTagSelection = (setState, key, _value, selected) =>
  setState(state =>
    {
      ...state,
      tagsSelection:
        state.tagsSelection
        |> Array.map(tagSelection => {
             let (tagId, tagName, _selected) = tagSelection;
             tagId == key ? (tagId, tagName, selected) : tagSelection;
           }),
    }
  );

module CreateCourseExportQuery = [%graphql
  {|
 mutation($courseId: ID!, $tagIds: [ID!]!, $reviewedOnly: Boolean!) {
  createCourseExport(courseId: $courseId, tagIds: $tagIds, reviewedOnly: $reviewedOnly){
    courseExport {
      id
      createdAt
      tags
      reviewedOnly
    }
   }
 }
|}
];

let deselectedTags = tags =>
  tags |> Array.map(tag => (tag |> Tag.id, tag |> Tag.name, false));

let createCourseExport =
    (course, tags, setCourseExports, state, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setState(state => {...state, saving: true});

  let tagIds =
    state.tagsSelection
    |> Array.to_list
    |> List.filter(((_, _, selected)) => selected)
    |> List.map(((tagId, _, _)) => tagId)
    |> Array.of_list;

  CreateCourseExportQuery.make(
    ~courseId=course |> Course.id,
    ~tagIds,
    ~reviewedOnly=state.reviewedOnly,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       switch (response##createCourseExport##courseExport) {
       | Some(export) =>
         /* Add the new course export to the list of exports known by this component. */
         let courseExport =
           CourseExport.make(
             ~id=export##id,
             ~createdAt=export##createdAt,
             ~tags=export##tags,
             ~reviewedOnly=export##reviewedOnly,
           );

         setCourseExports(oldExports =>
           [|courseExport|] |> Array.append(oldExports)
         );

         /* Then hide the form. */
         setState(_ =>
           {
             tagsSelection: tags |> deselectedTags,
             visible: false,
             saving: false,
             reviewedOnly: false,
           }
         );
       | None => setState(state => {...state, saving: false})
       };

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let reviewedOnlyButtonClasses = value => {
  let defaultClasses = "target-editor__completion-button relative flex flex-col items-center bg-white border border-gray-400 hover:bg-gray-200 text-sm font-semibold focus:outline-none rounded p-4 w-full";
  value
    ? defaultClasses
      ++ " target-editor__completion-button--selected bg-gray-200 text-primary-500 border-primary-500"
    : defaultClasses ++ " opacity-75 text-gray-900";
};

[@react.component]
let make = (~course, ~exports, ~tags) => {
  let (state, setState) =
    React.useState(() =>
      {
        visible: false,
        tagsSelection:
          tags |> Array.map(tag => (tag |> Tag.id, tag |> Tag.name, false)),
        saving: false,
        reviewedOnly: false,
      }
    );
  let (courseExports, setCourseExports) = React.useState(() => exports);

  <div
    key="School admin coaches course index"
    className="flex flex-1 h-screen overflow-y-scroll">
    {switch (state.visible) {
     | false => ReasonReact.null
     | true =>
       <SchoolAdmin__EditorDrawer
         closeDrawerCB={() => setState(state => {...state, visible: false})}
         closeButtonTitle="Close Export Form">
         <div className="mx-auto bg-white">
           <div className="max-w-2xl pt-6 px-6 mx-auto">
             <h5
               className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
               {"Export course data" |> str}
             </h5>
             <label className="block tracking-wide text-xs font-semibold mb-2">
               {"Export only students with the following tags:" |> str}
             </label>
             <School__SelectBox
               items={state.tagsSelection |> Array.to_list}
               selectCB={updateTagSelection(setState)}
               noSelectionHeading="No tags selected"
               noSelectionDescription="Select tags from the list to limit results to a select set of students."
               emptyListDescription="You haven't tagged any student yet."
             />
             <div className="mt-5">
               <label
                 className="block tracking-wide text-xs font-semibold mr-6 mb-3"
                 htmlFor="targets_filter">
                 {"Which targets should the export include?" |> str}
               </label>
               <div id="targets_filter" className="flex -mx-2">
                 <div className="w-1/2 px-2">
                   <button
                     onClick={_event => {
                       ReactEvent.Mouse.preventDefault(_event);
                       setState(state => {...state, reviewedOnly: false});
                     }}
                     className={reviewedOnlyButtonClasses(
                       !state.reviewedOnly,
                     )}>
                     {"All targets" |> str}
                   </button>
                 </div>
                 <div className="w-1/2 px-2">
                   <button
                     onClick={_event => {
                       ReactEvent.Mouse.preventDefault(_event);
                       setState(state => {...state, reviewedOnly: true});
                     }}
                     className={reviewedOnlyButtonClasses(state.reviewedOnly)}>
                     {"Only targets with reviewed submissions" |> str}
                   </button>
                 </div>
               </div>
             </div>
             <div className="flex max-w-2xl w-full mt-5 pb-5 mx-auto">
               <button
                 disabled={state.saving}
                 className="w-full btn btn-primary btn-large"
                 onClick={createCourseExport(
                   course,
                   tags,
                   setCourseExports,
                   state,
                   setState,
                 )}>
                 {if (state.saving) {
                    <span>
                      <FaIcon classes="fas fa-spinner fa-pulse" />
                      <span className="ml-2">
                        {"Setting up an export..." |> str}
                      </span>
                    </span>;
                  } else {
                    "Create Export" |> str;
                  }}
               </button>
             </div>
           </div>
         </div>
       </SchoolAdmin__EditorDrawer>
     }}
    <div className="flex-1 flex flex-col bg-gray-100">
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={event => {
            ReactEvent.Mouse.preventDefault(event);
            setState(state => {...state, visible: true});
          }}
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-20 cursor-pointer">
          <i className="fas fa-file-export text-lg" />
          <h5 className="font-semibold ml-2">
            {"Create a new export" |> str}
          </h5>
        </button>
      </div>
      {switch (courseExports) {
       | [||] =>
         <div
           className="flex justify-center bg-gray-100 border rounded p-3 italic mx-auto max-w-2xl w-full">
           {"You haven't exported anything yet!" |> str}
         </div>
       | exports =>
         <div className="px-6 pb-4 mt-5 flex flex-1 bg-gray-100">
           <div className="max-w-2xl w-full mx-auto relative">
             <h4 className="mt-5 w-full"> {"Exports" |> str} </h4>
             <div className="flex mt-4 -mx-3 items-start flex-wrap">
               {exports
                |> ArrayUtils.copyAndSort((x, y) =>
                     DateFns.differenceInSeconds(
                       y |> CourseExport.createdAt |> DateFns.parseString,
                       x |> CourseExport.createdAt |> DateFns.parseString,
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
                             <div
                               className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                               {courseExport |> CourseExport.reviewedOnly
                                  ? <span
                                      className="px-2 py-1 border rounded bg-secondary-100 text-primary-600 mt-1 mr-1">
                                      {"Reviewed Submissions Only" |> str}
                                    </span>
                                  : React.null}
                               {switch (courseExport |> CourseExport.tags) {
                                | [||] => ReasonReact.null
                                | tags =>
                                  tags
                                  |> Array.map(tag =>
                                       <span
                                         key=tag
                                         className="px-2 py-1 border rounded bg-primary-100 text-primary-600 mt-1 mr-1">
                                         {tag |> str}
                                       </span>
                                     )
                                  |> React.array
                                }}
                             </div>
                           </div>
                           {switch (courseExport |> CourseExport.file) {
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
                            }}
                         </div>
                       </div>
                     </div>
                   )
                |> React.array}
             </div>
           </div>
         </div>
       }}
    </div>
  </div>;
};
