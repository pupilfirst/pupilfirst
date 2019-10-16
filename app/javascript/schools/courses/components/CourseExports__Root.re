[@bs.config {jsx: 3}];

open CourseExports__Types;

let str = React.string;

type formState = {
  visible: bool,
  tagsSelection: array((Tag.id, string, bool)),
  saving: bool,
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

let updateTagSelection = (setFormState, key, _value, selected) =>
  setFormState(formState =>
    {
      ...formState,
      tagsSelection:
        formState.tagsSelection
        |> Array.map(tagSelection => {
             let (tagId, tagName, _selected) = tagSelection;
             tagId == key ? (tagId, tagName, selected) : tagSelection;
           }),
    }
  );

module CreateCoruseExportQuery = [%graphql
  {|
 mutation($courseId: ID!, $tagIds: [ID!]!) {
  createCourseExport(courseId: $courseId, tagIds: $tagIds){
    courseExport {
      id
      createdAt
      tags
    }
   }
 }
|}
];

let deselectedTags = tags =>
  tags |> Array.map(tag => (tag |> Tag.id, tag |> Tag.name, false));

let createCourseExport =
    (
      authenticityToken,
      course,
      tags,
      tagsSelection,
      setCourseExports,
      setFormState,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  setFormState(formState => {...formState, saving: true});

  let tagIds =
    tagsSelection
    |> Array.to_list
    |> List.filter(((_, _, selected)) => selected)
    |> List.map(((tagId, _, _)) => tagId)
    |> Array.of_list;

  CreateCoruseExportQuery.make(~courseId=course |> Course.id, ~tagIds, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##createCourseExport##courseExport) {
       | Some(export) =>
         /* Add the new course export to the list of exports known by this component. */
         let courseExport =
           CourseExport.make(
             ~id=export##id,
             ~createdAt=export##createdAt,
             ~tags=export##tags,
           );

         setCourseExports(oldExports =>
           [|courseExport|] |> Array.append(oldExports)
         );

         /* Then hide the form. */
         setFormState(_ =>
           {
             tagsSelection: tags |> deselectedTags,
             visible: false,
             saving: false,
           }
         );
       | None => setFormState(formState => {...formState, saving: false})
       };

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_ => {
       setFormState(formState => {...formState, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~authenticityToken, ~course, ~exports, ~tags) => {
  let (formState, setFormState) =
    React.useState(() =>
      {
        visible: false,
        tagsSelection:
          tags |> Array.map(tag => (tag |> Tag.id, tag |> Tag.name, false)),
        saving: false,
      }
    );
  let (courseExports, setCourseExports) = React.useState(() => exports);

  <div
    key="School admin coaches course index"
    className="flex flex-1 h-screen overflow-y-scroll">
    {
      switch (formState.visible) {
      | false => ReasonReact.null
      | true =>
        <SchoolAdmin__EditorDrawer
          closeDrawerCB=(
            () => setFormState(formState => {...formState, visible: false})
          )
          closeButtonTitle="Close Export Form">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl pt-6 px-6 mx-auto">
              <h5
                className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                {"Export course data" |> str}
              </h5>
              <label
                className="block tracking-wide text-xs font-semibold mb-2">
                {"Export only students with the following tags:" |> str}
              </label>
              <School__SelectBox
                items={formState.tagsSelection |> Array.to_list}
                selectCB={updateTagSelection(setFormState)}
                noSelectionHeading="No tags selected"
                noSelectionDescription="Select tags from the list to limit results to a select set of students."
                emptyListDescription="You haven't tagged any student yet."
              />
              <div className="flex max-w-2xl w-full mt-5 pb-5 mx-auto">
                <button
                  disabled={formState.saving}
                  className="w-full btn btn-primary btn-large"
                  onClick={
                    createCourseExport(
                      authenticityToken,
                      course,
                      tags,
                      formState.tagsSelection,
                      setCourseExports,
                      setFormState,
                    )
                  }>
                  {
                    if (formState.saving) {
                      <span>
                        <FaIcon classes="fas fa-spinner fa-pulse" />
                        <span className="ml-2">
                          {"Setting up an export..." |> str}
                        </span>
                      </span>;
                    } else {
                      "Create Export" |> str;
                    }
                  }
                </button>
              </div>
            </div>
          </div>
        </SchoolAdmin__EditorDrawer>
      }
    }
    <div className="flex-1 flex flex-col bg-gray-100">
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={
            event => {
              ReactEvent.Mouse.preventDefault(event);
              setFormState(formState => {...formState, visible: true});
            }
          }
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-20 cursor-pointer">
          <i className="fas fa-file-export text-lg" />
          <h5 className="font-semibold ml-2">
            {"Create a new export" |> str}
          </h5>
        </button>
      </div>
      {
        switch (courseExports) {
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
                {
                  exports
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
