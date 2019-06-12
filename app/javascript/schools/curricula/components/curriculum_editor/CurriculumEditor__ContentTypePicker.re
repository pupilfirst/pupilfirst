[@bs.config {jsx: 3}];

let str = React.string;

let buttonClasses = visibility => {
  let classes = "add-content-block";
  classes ++ (visibility ? " add-content-block--open" : " ");
};

[@react.component]
let make = (~sortIndex=?) => {
  let (visibility, setVisibility) = React.useState(() => false);
  <div className={buttonClasses(visibility)}>
    <div
      className="add-content-block__plus-button-container relative py-3"
      onClick={_event => setVisibility(_ => !visibility)}>
      <div
        className="add-content-block__plus-button bg-gray-200 hover:bg-gray-400 relative rounded-lg w-9 h-9 flex justify-center items-center mx-auto z-20">
        <i
          className="fal fa-plus text-xl add-content-block__plus-button-icon"
        />
      </div>
    </div>
    <div
      className="add-content-block__blocks hidden shadow-lg max-w-2xl mx-auto relative bg-primary-900 px-5 pt-6 pb-5 rounded-lg -mt-6 z-10">
      <div className="flex-1 text-center text-primary-200">
        <i className="fab fa-markdown text-3xl" />
        <p className="font-semibold mt-1"> {"Markdown" |> str} </p>
      </div>
      <div className="flex-1 text-center text-primary-200">
        <i className="far fa-image text-3xl" />
        <p className="font-semibold mt-1"> {"Image" |> str} </p>
      </div>
      <div className="flex-1 text-center text-primary-200">
        <i className="far fa-code text-3xl" />
        <p className="font-semibold mt-1"> {"Embed" |> str} </p>
      </div>
      <div className="flex-1 text-center text-primary-200">
        <i className="far fa-file-alt text-3xl" />
        <p className="font-semibold mt-1"> {"File" |> str} </p>
      </div>
    </div>
  </div>;
};