open CourseCertificates__Types;

let str = React.string;

type state = {
  drawerOpen: bool,
  saving: bool,
  certificates: array(Certificate.t),
};

let computeInitialState = certificates => {
  drawerOpen: false,
  saving: false,
  certificates,
};

type action =
  | OpenDrawer
  | CloseDrawer
  | BeginSaving
  | FinishSaving
  | FailSaving;

let reducer = (state, action) =>
  switch (action) {
  | OpenDrawer => {...state, drawerOpen: true}
  | CloseDrawer => {...state, drawerOpen: false}
  | BeginSaving => {...state, saving: true}
  | FinishSaving => {...state, saving: false, drawerOpen: false}
  | FailSaving => {...state, saving: false}
  };

[@react.component]
let make = (~course, ~certificates) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, certificates, computeInitialState);

  <div className="flex flex-1 h-screen overflow-y-scroll">
    {state.drawerOpen
       ? <SchoolAdmin__EditorDrawer
           size=SchoolAdmin__EditorDrawer.Large
           closeDrawerCB={() => send(CloseDrawer)}
           closeButtonTitle="Close Certificate Form">
           <div className="mx-auto bg-white">
             <div className="max-w-2xl pt-6 px-6 mx-auto">
               <h5
                 className="uppercase text-center border-b border-gray-400 pb-2">
                 {"Create new certificate" |> str}
               </h5>
               <div className="mt-4">
                 <label
                   className="block tracking-wide text-xs font-semibold mr-6 mb-2">
                   {"Please begin by uploading a base image:" |> str}
                 </label>
               </div>
               <div className="flex max-w-2xl w-full mt-5 pb-5 mx-auto">
                 <button
                   disabled={state.saving}
                   className="w-full btn btn-primary btn-large">
                   {if (state.saving) {
                      <span>
                        <FaIcon classes="fas fa-spinner fa-pulse" />
                        <span className="ml-2">
                          {"Creating certificate..." |> str}
                        </span>
                      </span>;
                    } else {
                      "Create certificate" |> str;
                    }}
                 </button>
               </div>
             </div>
           </div>
         </SchoolAdmin__EditorDrawer>
       : React.null}
    <div className="flex-1 flex flex-col bg-gray-100">
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={_ => {send(OpenDrawer)}}
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
          <i className="fas fa-plus-circle" />
          <h5 className="font-semibold ml-2">
            {"Create New Certificate" |> str}
          </h5>
        </button>
      </div>
      {state.certificates |> ArrayUtils.isEmpty
         ? <div
             className="flex justify-center bg-gray-100 border rounded p-3 italic mx-auto max-w-2xl w-full">
             {"You haven't created any certificates yet!" |> str}
           </div>
         : <div className="px-6 pb-4 mt-5 flex flex-1 bg-gray-100">
             <div className="max-w-2xl w-full mx-auto relative">
               <h4 className="mt-5 w-full"> {"Certificates" |> str} </h4>
               <div className="flex mt-4 -mx-3 items-start flex-wrap">
                 {state.certificates
                  |> ArrayUtils.copyAndSort((x, y) =>
                       DateFns.differenceInSeconds(
                         y |> Certificate.updatedAt,
                         x |> Certificate.updatedAt,
                       )
                     )
                  |> Array.map(certificate =>
                       <div
                         key={Certificate.id(certificate)}
                         ariaLabel={
                           "Certificate " ++ Certificate.id(certificate)
                         }
                         className="flex w-1/2 items-center mb-4 px-3">
                         <div
                           className="course-faculty__list-item shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                           <div className="flex flex-1 justify-between">
                             <div className="pt-4 pb-3 px-4">
                               <div className="text-sm">
                                 <p className="text-black font-semibold">
                                   {Certificate.name(certificate)->str}
                                 </p>
                                 <p
                                   className="text-gray-600 font-semibold text-xs mt-px">
                                   {str(
                                      "Issued "
                                      ++ Inflector.pluralize(
                                           "time",
                                           ~count=
                                             Certificate.issuedCertificates(
                                               certificate,
                                             ),
                                           ~inclusive=true,
                                           (),
                                         ),
                                    )}
                                 </p>
                               </div>
                               {Certificate.active(certificate)
                                  ? <div
                                      className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                                      <span
                                        className="px-2 py-1 border rounded bg-secondary-100 text-primary-600 mt-1 mr-1">
                                        {"Active" |> str}
                                      </span>
                                    </div>
                                  : React.null}
                             </div>
                             <div className="flex">
                               <a
                                 ariaLabel={
                                   "Edit Certificate "
                                   ++ Certificate.id(certificate)
                                 }
                                 className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                 href="#">
                                 <i className="fas fa-edit" />
                               </a>
                               {Certificate.issuedCertificates(certificate)
                                == 0
                                  ? <a
                                      ariaLabel={
                                        "Delete Certificate "
                                        ++ Certificate.id(certificate)
                                      }
                                      className="w-10 text-sm text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                                      href="#">
                                      <i className="fas fa-trash-alt" />
                                    </a>
                                  : React.null}
                             </div>
                           </div>
                         </div>
                       </div>
                     )
                  |> React.array}
               </div>
             </div>
           </div>}
    </div>
  </div>;
};
