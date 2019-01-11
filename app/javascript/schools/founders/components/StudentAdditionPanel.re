let component = ReasonReact.statelessComponent("StudentAdditionPanel");

let str = ReasonReact.string;

let make = (~courseId, _children) => {
  ...component,
  render: _self =>
    <div className="student-addition-panel__container">
      ("<Root div to hook StudentAdditionPanel for course " ++ (courseId |> string_of_int) ++ " on to>" |> str)
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
