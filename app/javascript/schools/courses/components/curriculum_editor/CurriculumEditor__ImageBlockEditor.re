[%bs.raw {|require("./CurriculumEditor__ImageBlockEditor.css")|}];

let str = React.string;

let onChangeCaption = (contentBlock, updateContentBlockCB, event) => {
  ReactEvent.Form.preventDefault(event);
  let newCaption = ReactEvent.Form.target(event)##value;
  let newContentBlock =
    ContentBlock.updateImageCaption(contentBlock, newCaption);
  updateContentBlockCB(newContentBlock);
};

let onChangeWidth = (contentBlock, updateContentBlockCB, event) => {
  ReactEvent.Form.preventDefault(event);
  let value = ReactEvent.Synthetic.target(event)##value;
  let width = ContentBlock.widthFromClass(value);
  let newContentBlock = ContentBlock.updateImageWidth(contentBlock, width);
  updateContentBlockCB(newContentBlock);
};

let imageResizeButton = (~width, ~currentWidth) => {
  let active = width == currentWidth;

  let defaultClasses = "rounded-l flex justify-center items-center px-4 py-2 h-full w-full hover:bg-primary-900 hover:text-green-400 transition duration-500 ease-in-out";

  let classes =
    defaultClasses ++ (active ? " bg-primary-900 text-green-500" : "");

  let iconClass =
    switch (width) {
    | ContentBlock.Auto => "i-image-auto"
    | Full => "i-image-fill-width"
    | FourFifths => "i-image-inset-80"
    | ThreeFifths => "i-image-inset-60"
    | TwoFifths => "i-image-inset-40"
    };

  <button className=classes>
    <Icon className={"if text-lg " ++ iconClass} />
  </button>;
};

let imageResizePanel = currentWidth =>
  <div
    className="image-block-editor__image-resize-panel flex justify-center absolute w-full top-0 opacity-0 transform translate-y-0 transition duration-500 ease-in-out">
    <div
      className="image-block-editor__image-resize-panel-box mx-auto rounded shadow-lg h-full">
      <div
        className="grid grid-cols-5 place-items-center text-white text-center">
        {imageResizeButton(~width=ContentBlock.Full, ~currentWidth)}
        {imageResizeButton(~width=ContentBlock.FourFifths, ~currentWidth)}
        {imageResizeButton(~width=ContentBlock.Auto, ~currentWidth)}
        {imageResizeButton(~width=ContentBlock.ThreeFifths, ~currentWidth)}
        {imageResizeButton(~width=ContentBlock.TwoFifths, ~currentWidth)}
      </div>
    </div>
  </div>;

[@react.component]
let make = (~url, ~caption, ~contentBlock, ~updateContentBlockCB, ~width) => {
  let captionInputId = "caption-" ++ (contentBlock |> ContentBlock.id);
  let widthInputId = "width-" ++ contentBlock.id;
  let widthClass = ContentBlock.widthToClass(width);

  <div className="image-block-editor__container">
    <div
      className="content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg">
      <div className="w-full">
        <div className="rounded-t-lg bg-white relative">
          {imageResizePanel(width)}
          <img
            className={"mx-auto w-auto md:" ++ widthClass}
            src=url
            alt=caption
          />
          {switch (caption) {
           | "" => React.null
           | caption =>
             <div className="px-4 py-2 text-sm italic text-center">
               {caption |> str}
             </div>
           }}
        </div>
      </div>
    </div>
    <div className="flex border-t justify-end">
      <div className="flex-1 content-block__action-bar-input p-3">
        <label htmlFor=captionInputId className="text-sm font-semibold">
          {"Caption" |> str}
        </label>
        <span className="text-sm ml-1"> {"(optional)" |> str} </span>
        <input
          id=captionInputId
          className="mt-1 appearance-none block w-full h-10 bg-white text-gray-800 border rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
          onChange={onChangeCaption(contentBlock, updateContentBlockCB)}
          maxLength=250
          type_="text"
          value=caption
          placeholder="A caption for the image"
        />
      </div>
    </div>
    <div className="flex border-t justify-end">
      <div className="flex-1 content-block__action-bar-input p-3">
        <label htmlFor=widthInputId className="text-sm font-semibold">
          {React.string("Width")}
        </label>
        <select
          className="cursor-pointer mt-1 appearance-none block w-full bg-white text-gray-800 border rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
          id=widthInputId
          value=widthClass
          onChange={onChangeWidth(contentBlock, updateContentBlockCB)}>
          <option value="w-auto"> "Auto"->React.string </option>
          <option value="w-full"> "Full"->React.string </option>
          <option value="w-4/5"> "4/5"->React.string </option>
          <option value="w-3/5"> "3/5"->React.string </option>
          <option value="w-2/5"> "2/5"->React.string </option>
        </select>
      </div>
    </div>
  </div>;
};
