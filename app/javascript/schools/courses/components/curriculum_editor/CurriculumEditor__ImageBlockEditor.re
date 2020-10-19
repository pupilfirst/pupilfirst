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
  <div className="relative border border-gray-400 rounded-lg">
    <div
      className={
        width === `auto
          ? ""
          : ("max-w-" ++ widthString ++ " mx-auto ")
            ++ "content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg"
      }>
      <div className="w-full">
        <div className="rounded-t-lg bg-white">
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
          "Width : "->React.string
          <select
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
        </label>
      </div>
    </div>
  </div>;
};
