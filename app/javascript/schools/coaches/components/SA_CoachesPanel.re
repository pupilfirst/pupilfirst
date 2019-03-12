open CoachesPanel__Types;

open SchoolAdmin__Utils;

let str = ReasonReact.string;

type formVisible =
  | None
  | CoachEditor(option(Coach.t));

type state = {
  coaches: list(Coach.t),
  searchString: string,
  formVisible,
};

type action =
  | CreateCoach
  | UpdateFormVisible(formVisible);

let component = ReasonReact.reducerComponent("SA_CoachesPanel");

let make = (~coaches, ~schoolId, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {coaches, searchString: "", formVisible: None},
  reducer: (action, state) =>
    switch (action) {
    | UpdateFormVisible(formVisible) =>
      ReasonReact.Update({...state, formVisible})
    },
  render: ({state, send}) => {
    let closeFormCB = () => send(UpdateFormVisible(None));
    <div className="flex flex-1 h-screen">
      (
        switch (state.formVisible) {
        | None => ReasonReact.null
        | CoachEditor(coach) =>
          <SA_CoachesPanel_CoachEditor
            schoolId
            coach
            closeFormCB
            authenticityToken
          />
        }
      )
      <div className="flex-1 flex flex-col bg-grey-lightest overflow-hidden">
        <div
          className="flex px-6 py-2 items-center justify-between overflow-y-scroll">
          <div
            onClick=(
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(UpdateFormVisible(CoachEditor(None)));
              }
            )
            className="max-w-md w-full flex mx-auto items-center justify-center relative bg-grey-lighter hover:bg-grey-light hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-12 cursor-pointer">
            <i className="material-icons"> ("add_circle_outline" |> str) </i>
            <h4 className="font-semibold ml-2"> ("Add New Coach" |> str) </h4>
          </div>
        </div>
        <div
          className="px-6 pb-4 mt-5 flex flex-1 bg-grey-lightest overflow-y-scroll">
          <div className="max-w-md w-full mx-auto relative">
            (
              coaches
              |> List.map(coach =>
                   <div
                     className="flex items-center shadow bg-white rounded-lg overflow-hidden mb-4">
                     <div
                       className="course-faculty__list-item flex w-full hover:bg-grey-lighter"
                       onClick=(
                         _event => {
                           ReactEvent.Mouse.preventDefault(_event);
                           send(
                             UpdateFormVisible(CoachEditor(Some(coach))),
                           );
                         }
                       )>
                       <div className="flex flex-1 items-center py-4 px-4">
                         <img
                           className="w-10 h-10 rounded-full mr-4"
                           src=(coach |> Coach.imageUrl)
                           alt="Avatar of Jonathan Reinink"
                         />
                         <div className="text-sm">
                           <p className="text-black font-semibold">
                             (coach |> Coach.name |> str)
                           </p>
                           <p
                             className="text-grey-dark font-semibold text-xs mt-1">
                             (coach |> Coach.title |> str)
                           </p>
                         </div>
                       </div>
                       <div
                         className="course-faculty__list-item-remove items-center p-4 flex invisible cursor-pointer">
                         <i className="material-icons">
                           ("delete_outline" |> str)
                         </i>
                       </div>
                     </div>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            )
          </div>
        </div>
      </div>
    </div>;
  },
};

type props = {
  coaches: list(Coach.t),
  authenticityToken: string,
  schoolId: int,
};

let decode = json =>
  Json.Decode.{
    coaches: json |> field("coaches", list(Coach.decode)),
    schoolId: json |> field("schoolId", int),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~coaches=props.coaches,
        ~schoolId=props.schoolId,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );