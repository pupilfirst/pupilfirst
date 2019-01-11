let component = ReasonReact.statelessComponent("StudentAdditionPanel");

let str = ReasonReact.string;

let make = (~courseId, _children) => {
  ...component,
  render: _self =>
    <div className="student-addition-panel__container">
      ("Student Addition Panel for course " ++ (courseId |> string_of_int) |> str)
    </div>,
};

type props = {courseId: int};

let decode = json => Json.Decode.{courseId: json |> field("courseId", int)};

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~courseId=props.courseId, [||]);
    },
  );
