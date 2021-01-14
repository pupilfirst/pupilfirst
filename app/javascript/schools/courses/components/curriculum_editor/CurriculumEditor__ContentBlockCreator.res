exception FormNotFound(string)

%bs.raw(`require("./CurriculumEditor__ContentBlockCreator.css")`)

open CurriculumEditor__Types

let str = React.string
let t = I18n.t(~scope="components.CurriculumEditor__ContentBlockCreator")

module CreateMarkdownContentBlock = %graphql(
  `
    mutation CreateMarkdownContentBlockMutation($targetId: ID!, $aboveContentBlockId: ID) {
      createMarkdownContentBlock(targetId: $targetId, aboveContentBlockId: $aboveContentBlockId) {
        contentBlock {
          ...ContentBlock.Fragments.AllFields
        }
      }
    }
  `
)

module CreateEmbedContentBlock = %graphql(
  `
    mutation CreateEmbedContentBlockMutation($targetId: ID!, $aboveContentBlockId: ID, $url: String!, $requestSource: EmbedRequestSource!) {
      createEmbedContentBlock(targetId: $targetId, aboveContentBlockId: $aboveContentBlockId, url: $url, requestSource: $requestSource) {
        contentBlock {
          ...ContentBlock.Fragments.AllFields
        }
      }
    }
  `
)

module CreateVimeoVideo = %graphql(
  `
    mutation CreateVimeoVideo($targetId: ID!, $size: Int!, $title: String, $description: String) {
      createVimeoVideo(targetId: $targetId, size: $size, title: $title, description: $description) {
        vimeoVideo {
          link
          uploadLink
        }
      }
    }
  `
)

type ui =
  | Hidden
  | BlockSelector
  | EmbedForm(string)
  | UploadVideo

type state = {
  ui: ui,
  saving: bool,
  uploadProgress: option<int>,
  videoTitle: string,
  videoDescription: string,
  error: option<string>,
}

type action =
  | ToggleVisibility
  | ToggleSaving
  | FinishSaving(bool)
  | SetError(string)
  | FailedToCreate
  | FailToUpload
  | ShowEmbedForm
  | UpdateVideoTitle(string)
  | UpdateVideoDescription(string)
  | HideEmbedForm
  | HideUploadVideoForm
  | ShowUploadVideoForm
  | UpdateUploadProgress(int)
  | UpdateEmbedUrl(string)

let computeInitialState = isAboveTarget => {
  ui: isAboveTarget ? Hidden : BlockSelector,
  saving: false,
  error: None,
  uploadProgress: None,
  videoTitle: "",
  videoDescription: "",
}

let reducer = (state, action) =>
  switch action {
  | ToggleVisibility =>
    let ui = switch state.ui {
    | Hidden => BlockSelector
    | BlockSelector
    | UploadVideo
    | EmbedForm(_) =>
      Hidden
    }

    {...state, ui: ui}
  | ToggleSaving => {...state, saving: !state.saving, error: None}
  | FinishSaving(isAboveTarget) => computeInitialState(isAboveTarget)
  | SetError(error) => {...state, error: Some(error)}
  | FailedToCreate => {
      ...state,
      saving: false,
      error: Some("An unexpected error occured. Please reload the page and try again."),
    }
  | FailToUpload => {
      ...state,
      saving: false,
      error: Some("Failed to upload file. Please check message in notification, and try again."),
    }
  | ShowEmbedForm => {...state, ui: EmbedForm("")}
  | HideEmbedForm => {...state, ui: BlockSelector}
  | ShowUploadVideoForm => {...state, ui: UploadVideo}
  | HideUploadVideoForm => {...state, ui: BlockSelector}
  | UpdateEmbedUrl(url) => {...state, ui: EmbedForm(url)}
  | UpdateVideoTitle(videoTitle) => {...state, videoTitle: videoTitle}
  | UpdateVideoDescription(videoDescription) => {...state, videoDescription: videoDescription}
  | UpdateUploadProgress(uploadProgress) => {
      ...state,
      uploadProgress: Some(uploadProgress),
    }
  }

let containerClasses = (visible, isAboveTarget) => {
  let classes = "content-block-creator py-3"
  classes ++ (visible || !isAboveTarget ? " content-block-creator--open" : "")
}

let handleGraphqlCreateResponse = (aboveContentBlock, send, addContentBlockCB, contentBlock) => {
  switch contentBlock {
  | Some(contentBlock) =>
    contentBlock |> ContentBlock.makeFromJs |> addContentBlockCB
    send(FinishSaving(aboveContentBlock != None))
  | None => send(ToggleSaving)
  }

  Js.Promise.resolve()
}

let createMarkdownContentBlock = (target, aboveContentBlock, send, addContentBlockCB) => {
  send(ToggleSaving)
  let aboveContentBlockId = aboveContentBlock |> OptionUtils.map(ContentBlock.id)
  let targetId = target |> Target.id
  CreateMarkdownContentBlock.make(~targetId, ~aboveContentBlockId?, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result =>
    handleGraphqlCreateResponse(
      aboveContentBlock,
      send,
      addContentBlockCB,
      result["createMarkdownContentBlock"]["contentBlock"],
    )
  )
  |> Js.Promise.catch(_ => {
    send(FailedToCreate)
    Js.Promise.resolve()
  })
  |> ignore
}

let elementId = (prefix, aboveContentBlock) =>
  prefix ++
  switch aboveContentBlock {
  | Some(contentBlock) => contentBlock |> ContentBlock.id
  | None => "bottom"
  }

let fileInputId = aboveContentBlock => aboveContentBlock |> elementId("markdown-block-file-input-")
let imageInputId = aboveContentBlock =>
  aboveContentBlock |> elementId("markdown-block-image-input-")
let videoInputId = aboveContentBlock =>
  aboveContentBlock |> elementId("markdown-block-vimeo-input-")
let videoFormId = aboveContentBlock => aboveContentBlock |> elementId("markdown-block-vimeo-form-")
let fileFormId = aboveContentBlock => aboveContentBlock |> elementId("markdown-block-file-form-")
let imageFormId = aboveContentBlock => aboveContentBlock |> elementId("markdown-block-image-form-")

let onBlockTypeSelect = (target, aboveContentBlock, send, addContentBlockCB, blockType, _event) =>
  switch blockType {
  | #Markdown => createMarkdownContentBlock(target, aboveContentBlock, send, addContentBlockCB)
  | #File
  | #Image => ()
  | #Embed => send(ShowEmbedForm)
  | #VideoEmbed => send(ShowUploadVideoForm)
  }

let button = (target, aboveContentBlock, send, addContentBlockCB, blockType) => {
  let fileId = aboveContentBlock |> fileInputId
  let imageId = aboveContentBlock |> imageInputId
  let videoId = aboveContentBlock |> videoInputId

  let (faIcon, buttonText, htmlFor) = switch blockType {
  | #Markdown => ("fab fa-markdown", t("button_labels.markdown"), None)
  | #File => ("far fa-file-alt", t("button_labels.file"), Some(fileId))
  | #Image => ("far fa-image", t("button_labels.image"), Some(imageId))
  | #Embed => ("fas fa-code", t("button_labels.embed"), None)
  | #VideoEmbed => ("fab fa-vimeo-v", t("button_labels.video"), Some(videoId))
  }

  <label
    ?htmlFor
    key=buttonText
    className="content-block-creator__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
    onClick={onBlockTypeSelect(target, aboveContentBlock, send, addContentBlockCB, blockType)}>
    <i className={faIcon ++ " text-2xl"} /> <p className="font-semibold"> {str(buttonText)} </p>
  </label>
}

let embedUrlRegexes = [
  %bs.re("/https:\\/\\/.*slideshare\\.net/"),
  %bs.re("/https:\\/\\/.*vimeo\\.com/"),
  %bs.re("/https:\\/\\/.*youtube\\.com/"),
  %bs.re("/https:\\/\\/.*youtu\\.be/"),
  %bs.re("/https:\\/\\/docs\\.google\\.com\\/presentation/"),
  %bs.re("/https:\\/\\/docs\\.google\\.com\\/document/"),
  %bs.re("/https:\\/\\/docs\\.google\\.com\\/spreadsheets/"),
  %bs.re("/https:\\/\\/docs\\.google\\.com\\/forms/"),
]

let validEmbedUrl = url => Belt.Array.some(embedUrlRegexes, regex => regex->Js.Re.test_(url))

let handleCreateEmbedContentBlock = (
  target,
  aboveContentBlock,
  url,
  send,
  addContentBlockCB,
  requestSource,
) =>
  if url |> validEmbedUrl {
    send(ToggleSaving)

    let aboveContentBlockId = aboveContentBlock |> OptionUtils.map(ContentBlock.id)

    let targetId = target |> Target.id

    CreateEmbedContentBlock.make(~targetId, ~aboveContentBlockId?, ~url, ~requestSource, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(result =>
      handleGraphqlCreateResponse(
        aboveContentBlock,
        send,
        addContentBlockCB,
        result["createEmbedContentBlock"]["contentBlock"],
      )
    )
    |> Js.Promise.catch(_ => {
      send(FailedToCreate)
      Js.Promise.resolve()
    })
    |> ignore
  } else {
    Js.log(url ++ " File get error")
    send(
      SetError(
        "The URL doesn't look valid. Please make sure that it starts with 'https://' and that it's one of the accepted websites.",
      ),
    )
  }

let uploadOnProgress = (send, current, total) => {
  let progress = int_of_float(float_of_int(current) /. float_of_int(total) *. 100.00)

  send(UpdateUploadProgress(progress))
}

let handleVimeoVideoUpload = (
  file,
  vimeoVideo,
  send,
  target,
  aboveContentBlock,
  addContentBlockCB,
) => {
  let url = vimeoVideo["link"]
  let uploadUrl = vimeoVideo["uploadLink"]

  let onSuccess = () =>
    handleCreateEmbedContentBlock(
      target,
      aboveContentBlock,
      url,
      send,
      addContentBlockCB,
      #VimeoUpload,
    )

  EnvUtils.isTest()
    ? onSuccess()
    : Tus.upload(
        ~file=Tus.makeFile(file),
        ~uploadUrl,
        ~onError=error => {
          Js.log(error)
          send(FailToUpload)
        },
        ~onSuccess,
        ~onProgress=uploadOnProgress(send),
      )
}

let uploadFile = (
  target,
  send,
  addContentBlockCB,
  aboveContentBlock,
  blockType,
  file,
  state,
  formData,
) => {
  let isAboveContentBlock = aboveContentBlock != None
  switch blockType {
  | #File
  | #Image =>
    Api.sendFormData(
      "/school/targets/" ++ ((target |> Target.id) ++ "/content_block"),
      formData,
      json => {
        Notification.success("Done!", "File uploaded successfully.")
        let contentBlock = json |> ContentBlock.decode
        addContentBlockCB(contentBlock)
        send(FinishSaving(isAboveContentBlock))
      },
      () => send(FailToUpload),
    )
  | #VideoEmbed =>
    let size = file["size"]

    let title = String.trim(state.videoTitle) == "" ? None : Some(state.videoTitle)

    let description =
      String.trim(state.videoDescription) == "" ? None : Some(state.videoDescription)

    CreateVimeoVideo.make(~targetId=Target.id(target), ~size, ~title?, ~description?, ())
    |> GraphqlQuery.sendQuery
    |> Js.Promise.then_(result => {
      switch result["createVimeoVideo"]["vimeoVideo"] {
      | Some(vimeoVideo) =>
        handleVimeoVideoUpload(file, vimeoVideo, send, target, aboveContentBlock, addContentBlockCB)
      | None => send(FailedToCreate)
      }
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(_ => {
      send(FailedToCreate)
      Js.Promise.resolve()
    })
    |> ignore
  }
}

let submitForm = (target, aboveContentBlock, state, send, addContentBlockCB, blockType, file) => {
  let formId = switch blockType {
  | #File => fileFormId(aboveContentBlock)
  | #Image => imageFormId(aboveContentBlock)
  | #VideoEmbed => videoFormId(aboveContentBlock)
  }

  let element = ReactDOMRe._getElementById(formId)

  switch element {
  | Some(element) =>
    DomUtils.FormData.create(element) |> uploadFile(
      target,
      send,
      addContentBlockCB,
      aboveContentBlock,
      blockType,
      file,
      state,
    )
  | None =>
    Rollbar.error("Could not find form to upload file for content block: " ++ formId)
    raise(FormNotFound(formId))
  }
}

let maxVideoSize = vimeoPlan => {
  switch vimeoPlan {
  | Some(plan) =>
    switch plan {
    | VimeoPlan.Basic => 500 * 1024 * 1024
    | Plus
    | Pro
    | Business
    | Premium =>
      5000 * 1024 * 1024
    }
  | None => FileUtils.defaultVideoMaxSize
  }
}

let maxVideoSizeString = vimeoPlan => {
  switch vimeoPlan {
  | Some(plan) =>
    switch plan {
    | VimeoPlan.Basic => "500 MB"
    | Plus
    | Pro
    | Business
    | Premium => "5 GB"
    }
  | None => "500 MB"
  }
}

let handleFileInputChange = (
  target,
  aboveContentBlock,
  state,
  send,
  addContentBlockCB,
  vimeoPlan,
  blockType,
  event,
) => {
  event |> ReactEvent.Form.preventDefault

  switch ReactEvent.Form.target(event)["files"] {
  | [] => ()
  | files =>
    let file = files[0]

    let error = switch blockType {
    | #File => FileUtils.isInvalid(file) ? Some(t("file.upload_size_warning")) : None
    | #Image =>
      FileUtils.isInvalid(~image=true, file) ? Some(t("image.invalid_image_warning")) : None
    | #VideoEmbed =>
      let maxVideoSize = maxVideoSize(vimeoPlan)
      switch (FileUtils.isVideo(file), FileUtils.hasValidSize(~maxSize=maxVideoSize, file)) {
      | (false, true | false) => Some(t("video.invalid_format_warning"))
      | (true, false) =>
        Some(
          t(
            ~variables=[("maximumVideoSize", maxVideoSizeString(vimeoPlan))],
            "video.upload_limit_warning",
          ),
        )
      | (true, true) => None
      }
    }

    switch error {
    | Some(error) => send(SetError(error))
    | None =>
      // let filename = file##name;
      send(ToggleSaving)
      submitForm(target, aboveContentBlock, state, send, addContentBlockCB, blockType, file)
    }
  }
}

let uploadForm = (
  target,
  aboveContentBlock,
  state,
  send,
  addContentBlockCB,
  blockType,
  vimeoPlan,
) => {
  let fileSelectionHandler = handleFileInputChange(
    target,
    aboveContentBlock,
    state,
    send,
    addContentBlockCB,
    vimeoPlan,
  )

  let (fileId, formId, onChange, fileType) = switch blockType {
  | #File => (
      fileInputId(aboveContentBlock),
      fileFormId(aboveContentBlock),
      fileSelectionHandler(#File),
      "file",
    )
  | #Image => (
      imageInputId(aboveContentBlock),
      imageFormId(aboveContentBlock),
      fileSelectionHandler(#Image),
      "image",
    )
  | #VideoEmbed => (
      videoInputId(aboveContentBlock),
      videoFormId(aboveContentBlock),
      fileSelectionHandler(#VideoEmbed),
      "video",
    )
  }

  <form className="hidden" id=formId>
    <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
    <input type_="hidden" name="block_type" value=fileType />
    <input type_="file" name="file" id=fileId onChange required=true multiple=false />
    {switch aboveContentBlock {
    | Some(contentBlock) =>
      <input type_="hidden" name="above_content_block_id" value={contentBlock |> ContentBlock.id} />
    | None => React.null
    }}
  </form>
}

let visible = state =>
  switch state.ui {
  | Hidden => false
  | BlockSelector
  | UploadVideo
  | EmbedForm(_) => true
  }

let updateEmbedUrl = (send, event) => {
  let value = ReactEvent.Form.target(event)["value"]
  send(UpdateEmbedUrl(value))
}

let updateVideoTitle = (send, event) => {
  let value = ReactEvent.Form.target(event)["value"]
  send(UpdateVideoTitle(value))
}

let updateVideoDescription = (send, event) => {
  let value = ReactEvent.Form.target(event)["value"]
  send(UpdateVideoDescription(value))
}

let onEmbedFormSave = (target, aboveContentBlock, url, send, addContentBlockCB, event) => {
  event |> ReactEvent.Mouse.preventDefault

  handleCreateEmbedContentBlock(target, aboveContentBlock, url, send, addContentBlockCB, #User)
}

let topButton = (handler, id, title, icon) =>
  <div
    className="content-block-creator__top-button-container relative cursor-pointer" onClick=handler>
    <div
      id={"top-button-" ++ id}
      title
      className="content-block-creator__top-button bg-gray-200 hover:bg-gray-300 relative rounded-lg border border-gray-500 w-10 h-10 flex justify-center items-center mx-auto z-20">
      <FaIcon classes={"text-base fas " ++ icon} />
    </div>
  </div>

let closeEmbedFormButton = (send, aboveContentBlock) => {
  let id = aboveContentBlock |> OptionUtils.map(ContentBlock.id) |> OptionUtils.default("bottom")

  topButton(_e => send(HideEmbedForm), id, "Close Embed Form", "fa-level-up-alt")
}

let closeUploadFormButton = (send, aboveContentBlock) => {
  let id = aboveContentBlock->Belt.Option.mapWithDefault("button", ContentBlock.id)

  topButton(_e => send(HideUploadVideoForm), id, "Close Embed Form", "fa-level-up-alt")
}

let toggleVisibilityButton = (send, contentBlock) =>
  topButton(
    _e => send(ToggleVisibility),
    contentBlock |> ContentBlock.id,
    "Toggle Content Block Form",
    "fa-plus content-block-creator__plus-button-icon",
  )

let buttonAboveContentBlock = (state, send, aboveContentBlock) =>
  switch (state.ui, aboveContentBlock) {
  | (EmbedForm(_), Some(_) | None) => closeEmbedFormButton(send, aboveContentBlock)
  | (UploadVideo, Some(_) | None) => closeUploadFormButton(send, aboveContentBlock)
  | (Hidden, None)
  | (BlockSelector, None) =>
    <div className="h-10" /> // Spacer.
  | (Hidden | BlockSelector, Some(contentBlock)) => toggleVisibilityButton(send, contentBlock)
  }

let uploadVideoForm = (videoInputId, state, send) =>
  <div>
    <div className="mt-1">
      <label htmlFor={videoInputId ++ "-title"} className="text-xs font-semibold">
        {t("video.title_label")->str}
      </label>
      <input
        id={videoInputId ++ "-title"}
        placeholder="Title of your video"
        className="w-full py-1 px-2 border rounded"
        type_="text"
        value=state.videoTitle
        onChange={updateVideoTitle(send)}
        maxLength=120
      />
    </div>
    <div className="mt-1">
      <label htmlFor={videoInputId ++ "-description"} className="text-xs font-semibold">
        {t("video.description_label")->str}
      </label>
      <textarea
        id={videoInputId ++ "-description"}
        placeholder="Description for your video"
        className="w-full py-1 px-2 border rounded"
        type_="text"
        value=state.videoDescription
        onChange={updateVideoDescription(send)}
        maxLength=4000
        rows=4
      />
    </div>
    <label htmlFor=videoInputId className="mt-2 btn btn-success">
      {t("video.select_file_button")->str}
    </label>
  </div>

let disablingCoverDisabled = (saving, uploadProgress) =>
  uploadProgress->Belt.Option.mapWithDefault(saving, _u => false)

@react.component
let make = (
  ~target,
  ~aboveContentBlock=?,
  ~addContentBlockCB,
  ~hasVimeoAccessToken,
  ~vimeoPlan,
) => {
  let (embedInputId, isAboveContentBlock) = switch aboveContentBlock {
  | Some(contentBlock) =>
    let id = "embed-" ++ (contentBlock |> ContentBlock.id)
    (id, true)
  | None => ("embed-bottom", false)
  }

  let videoInputId = videoInputId(aboveContentBlock)

  let (state, send) = React.useReducerWithMapState(
    reducer,
    isAboveContentBlock,
    computeInitialState,
  )

  let uploadFormCurried = uploadType =>
    uploadForm(target, aboveContentBlock, state, send, addContentBlockCB, uploadType, vimeoPlan)

  <DisablingCover
    disabled={disablingCoverDisabled(state.saving, state.uploadProgress)}
    message={switch state.ui {
    | UploadVideo => "Preparing to Upload..."
    | BlockSelector
    | EmbedForm(_)
    | Hidden => "Creating..."
    }}>
    {uploadFormCurried(#File)}
    {uploadFormCurried(#Image)}
    <div className={containerClasses(state |> visible, isAboveContentBlock)}>
      {buttonAboveContentBlock(state, send, aboveContentBlock)}
      <div className="content-block-creator__inner-container">
        {switch state.ui {
        | Hidden => React.null
        | BlockSelector =>
          <div
            className="content-block-creator__block-content-type text-sm hidden shadow-lg mx-auto relative bg-primary-900 rounded-lg -mt-4 z-10">
            {(
              hasVimeoAccessToken
                ? [#Markdown, #Image, #Embed, #VideoEmbed, #File]
                : [#Markdown, #Image, #Embed, #File]
            )
            |> Array.map(button(target, aboveContentBlock, send, addContentBlockCB))
            |> React.array}
          </div>
        | UploadVideo =>
          <div
            className="clearfix border-2 border-gray-400 bg-gray-200 border-dashed rounded-lg px-3 pb-3 pt-2 -mt-4 z-10">
            {uploadFormCurried(#VideoEmbed)}
            {state.uploadProgress->Belt.Option.mapWithDefault(
              uploadVideoForm(videoInputId, state, send),
              current =>
                <div className="max-w-xs mx-auto">
                  <DoughnutChart
                    mode={current == 100
                      ? DoughnutChart.Indeterminate
                      : DoughnutChart.Determinate(current, 100)}
                    className="mx-auto my-20"
                  />
                  <div className="text-center font-semibold text-primary-800 mt-2">
                    {t("video.uploading")->str}
                  </div>
                </div>,
            )}
          </div>
        | EmbedForm(url) =>
          <div
            className="clearfix border-2 border-gray-400 bg-gray-200 border-dashed rounded-lg px-3 pb-3 pt-2 -mt-4 z-10">
            <label htmlFor=embedInputId className="text-xs font-semibold">
              {t("embed.url_label")->str}
            </label>
            <HelpIcon
              className="ml-2 text-xs"
              link="https://docs.pupilfirst.com/#/curriculum_editor?id=content-block-types">
              {t("embed.url_help")->str}
            </HelpIcon>
            <div className="flex mt-1">
              <input
                id=embedInputId
                placeholder="https://www.youtube.com/watch?v="
                className="w-full py-1 px-2 border rounded"
                type_="text"
                value=url
                onChange={updateEmbedUrl(send)}
              />
              <button
                className="ml-2 btn btn-success"
                onClick={onEmbedFormSave(target, aboveContentBlock, url, send, addContentBlockCB)}>
                {t("embed.save_button")->str}
              </button>
            </div>
          </div>
        }}
      </div>
      {switch state.error {
      | Some(error) => <School__InputGroupError message=error active={state |> visible} />
      | None => React.null
      }}
    </div>
  </DisablingCover>
}
