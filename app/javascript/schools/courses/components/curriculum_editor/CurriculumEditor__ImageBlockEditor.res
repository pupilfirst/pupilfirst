%bs.raw(`require("./CurriculumEditor__ImageBlockEditor.css")`)

let str = React.string
let t = I18n.t(~scope="components.CurriculumEditor__ImageBlockEditor")

let onChangeCaption = (contentBlock, updateContentBlockCB, event) => {
  ReactEvent.Form.preventDefault(event)
  let newCaption = ReactEvent.Form.target(event)["value"]
  let newContentBlock = ContentBlock.updateImageCaption(contentBlock, newCaption)
  updateContentBlockCB(newContentBlock)
}

let onChangeWidth = (contentBlock, updateContentBlockCB, width, event) => {
  ReactEvent.Mouse.preventDefault(event)
  let newContentBlock = ContentBlock.updateImageWidth(contentBlock, width)
  updateContentBlockCB(newContentBlock)
}

let imageResizeButton = (~width, ~currentWidth, ~contentBlock, ~updateContentBlockCB) => {
  let active = width == currentWidth

  let defaultClasses = "rounded-l flex justify-center items-center px-4 py-2 h-full w-full hover:bg-primary-900 hover:text-green-400 transition duration-500 ease-in-out"

  let classes = defaultClasses ++ (active ? " bg-primary-900 text-green-500" : "")

  let iconClass = switch width {
  | ContentBlock.Auto => "i-image-auto"
  | Full => "i-image-fill-width"
  | FourFifths => "i-image-inset-80"
  | ThreeFifths => "i-image-inset-60"
  | TwoFifths => "i-image-inset-40"
  }

  let title = switch width {
  | ContentBlock.Auto => t("resize_panel_button_title.auto")
  | Full => t("resize_panel_button_title.full")
  | FourFifths => t("resize_panel_button_title.four_fifths")
  | ThreeFifths => t("resize_panel_button_title.three_fifths")
  | TwoFifths => t("resize_panel_button_title.two_fifths")
  }

  <button
    title className=classes onClick={onChangeWidth(contentBlock, updateContentBlockCB, width)}>
    <Icon className={"if text-lg " ++ iconClass} />
  </button>
}

let imageResizePanel = (currentWidth, contentBlock, updateContentBlockCB) => {
  let button = imageResizeButton(~currentWidth, ~contentBlock, ~updateContentBlockCB)

  <div
    className="image-block-editor__image-resize-panel flex justify-center absolute w-full top-0 opacity-0 transform translate-y-0 transition duration-500 ease-in-out">
    <div className="image-block-editor__image-resize-panel-box mx-auto rounded shadow-lg h-full">
      <div className="grid grid-cols-5 place-items-center text-white text-center">
        {button(~width=ContentBlock.Full)}
        {button(~width=ContentBlock.FourFifths)}
        {button(~width=ContentBlock.Auto)}
        {button(~width=ContentBlock.ThreeFifths)}
        {button(~width=ContentBlock.TwoFifths)}
      </div>
    </div>
  </div>
}

@react.component
let make = (~url, ~caption, ~contentBlock, ~updateContentBlockCB, ~width) => {
  let captionInputId = "caption-" ++ (contentBlock |> ContentBlock.id)
  let widthClass = ContentBlock.widthToClass(width)

  <div className="image-block-editor__container">
    <div
      className="content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg">
      <div className="w-full">
        <div className="rounded-t-lg bg-white relative">
          {imageResizePanel(width, contentBlock, updateContentBlockCB)}
          <img className={"mx-auto w-auto md:" ++ widthClass} src=url alt=caption />
          {switch caption {
          | "" => React.null
          | caption =>
            <div className="px-4 py-2 text-sm italic text-center"> {caption |> str} </div>
          }}
        </div>
      </div>
    </div>
    <div className="flex border-t justify-end">
      <div className="flex-1 content-block__action-bar-input p-3">
        <label htmlFor=captionInputId className="text-sm font-semibold"> {"Caption" |> str} </label>
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
  </div>
}
