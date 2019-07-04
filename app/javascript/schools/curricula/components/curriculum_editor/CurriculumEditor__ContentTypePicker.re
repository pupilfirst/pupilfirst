[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

let buttonClasses = (visibility, staticMode) => {
  let classes = "add-content-block py-3";
  classes ++ (visibility || staticMode ? " add-content-block--open" : " ");
};

[@react.component]
let make = (~sortIndex, ~staticMode, ~newContentBlockCB) => {
  let (visibility, setVisibility) = React.useState(() => false);
  <div className={buttonClasses(visibility, staticMode)}>
    {
      staticMode ?
        <div className="[ add-content-block__staticmode-spacer ] h-10" /> :
        <div
          className="add-content-block__plus-button-container relative"
          onClick={_event => setVisibility(_ => !visibility)}>
          <div
            id={"add-block-" ++ (sortIndex |> string_of_int)}
            title="Add block"
            className="add-content-block__plus-button text-gray-700 bg-gray-200 hover:bg-gray-300 relative rounded-lg border border-gray-400 w-7 h-7 flex justify-center items-center mx-auto z-20">
            <i
              className="fal fa-plus text-base add-content-block__plus-button-icon"
            />
          </div>
        </div>
    }
    <div
      className="add-content-block__block-content-type hidden shadow-lg mx-auto relative bg-primary-900 rounded-lg -mt-3 z-10">
      <div
        className="add-content-block__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
        onClick={
          _event => {
            setVisibility(_ => !visibility);
            newContentBlockCB(sortIndex, ContentBlock.makeMarkdownBlock(""));
          }
        }>
        <i className="fab fa-markdown text-2xl" />
        <p className="font-semibold"> {"Markdown" |> str} </p>
      </div>
      <div
        className="add-content-block__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
        onClick={
          _event => {
            setVisibility(_ => !visibility);
            newContentBlockCB(
              sortIndex,
              ContentBlock.makeImageBlock("", ""),
            );
          }
        }>
        <i className="far fa-image text-2xl" />
        <p className="font-semibold"> {"Image" |> str} </p>
      </div>
      <div
        className="add-content-block__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
        onClick={
          _event => {
            setVisibility(_ => !visibility);
            newContentBlockCB(
              sortIndex,
              ContentBlock.makeEmbedBlock("", ""),
            );
          }
        }>
        <i className="far fa-code text-2xl" />
        <p className="font-semibold"> {"Embed" |> str} </p>
      </div>
      <div
        className="add-content-block__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
        onClick={
          _event => {
            setVisibility(_ => !visibility);
            newContentBlockCB(
              sortIndex,
              ContentBlock.makeFileBlock("", "", ""),
            );
          }
        }>
        <i className="far fa-file-alt text-2xl" />
        <p className="font-semibold"> {"File" |> str} </p>
      </div>
    </div>
  </div>;
};
