[%bs.raw {|require("./CurriculumEditor__ImageBlockEditor.css")|}];

let str = React.string;

let onChangeCaption = (contentBlock, updateContentBlockCB, event) => {
  event |> ReactEvent.Form.preventDefault;
  let newCaption = ReactEvent.Form.target(event)##value;
  let newContentBlock = contentBlock |> ContentBlock.updateImage(newCaption);
  updateContentBlockCB(newContentBlock);
};

[@react.component]
let make =
    (
      ~url,
      ~caption,
      ~contentBlock,
      ~updateContentBlockCB,
      ~width: ContentBlock.width,
    ) => {
  let captionInputId = "caption-" ++ (contentBlock |> ContentBlock.id);
  let widthInputId = "width-" ++ contentBlock.id;

  let widthString = ContentBlock.widthToString(width);
  <div className="image-block-editor__container">
    <div
      className={
        width === `auto
          ? ""
          : ("max-w-" ++ widthString ++ " mx-auto ")
            ++ "content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg"
      }>
      <div className="w-full">
        <div className="rounded-t-lg bg-white relative">
          <div
            className="image-block-editor__image-resize-panel absolute w-full top-0 opacity-0 transform translate-y-0 transition duration-500 ease-in-out">
            <div
              className="image-block-editor__image-resize-panel-box mx-auto w-full rounded shadow-lg h-full max-w-xs">
              <ul
                className="grid grid-cols-5 place-items-center text-white text-center">
                <li>
                  <button
                    className="rounded-l flex justify-center items-center p-2 h-full w-full hover:bg-primary-900 focus:bg-primary-900 active:bg-primary-900 hover:text-green-400 focus:text-green-400 active:text-green-500 transition duration-500 ease-in-out">
                    <Icon className="if i-image-fill-width text-xl" />
                  </button>
                </li>
                <li>
                  <button
                    className="flex justify-center items-center p-2 h-full w-full hover:bg-primary-900 focus:bg-primary-900 active:bg-primary-900 hover:text-green-400 focus:text-green-400 active:text-green-500 transition duration-500 ease-in-out">
                    <Icon className="if i-image-inset-80 text-xl" />
                  </button>
                </li>
                <li>
                  <button
                    className="flex justify-center items-center p-2 h-full w-full hover:bg-primary-900 focus:bg-primary-900 active:bg-primary-900 hover:text-green-400 focus:text-green-400 active:text-green-500 transition duration-500 ease-in-out">
                    <Icon className="if i-image-auto text-xl" />
                  </button>
                </li>
                <li>
                  <button
                    className="flex justify-center items-center p-2 h-full w-full hover:bg-primary-900 focus:bg-primary-900 active:bg-primary-900 hover:text-green-400 focus:text-green-400 active:text-green-500 transition duration-500 ease-in-out">
                    <Icon className="if i-image-inset-60 text-xl" />
                  </button>
                </li>
                <li>
                  <button
                    className="rounded-r flex justify-center items-center p-2 h-full w-full hover:bg-primary-900 focus:bg-primary-900 active:bg-primary-900 hover:text-green-400 focus:text-green-400 active:text-green-500 transition duration-500 ease-in-out">
                    <Icon className="if i-image-inset-40 text-xl" />
                  </button>
                </li>
              </ul>
            </div>
          </div>
          <img className="mx-auto" src=url alt=caption />
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
          value=widthString
          onChange={_event => {
            _event |> ReactEvent.Form.preventDefault;

            let value: string = ReactEvent.Synthetic.target(_event)##value;
            let width =
              switch (value) {
              | "xs" => `xs
              | "sm" => `sm
              | "md" => `md
              | "lg" => `lg
              | "xl" => `xl
              | "2xl" => `xl2
              | _ => `auto
              };
            updateContentBlockCB({
              ...contentBlock,
              blockType: Image(url, caption, width),
            });
            ();
          }}>
          <option value="auto"> "auto"->React.string </option>
          <option value="xs"> "xs"->React.string </option>
          <option value="sm"> "sm"->React.string </option>
          <option value="md"> "md"->React.string </option>
          <option value="lg"> "lg"->React.string </option>
          <option value="xl"> "xl"->React.string </option>
          <option value="2xl"> "2xl"->React.string </option>
        </select>
      </div>
    </div>
  </div>;
};
