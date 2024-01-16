exception FormNotFound(string)

%%raw(`import "./CurriculumEditor__ContentBlockCreator.css"`)

open CurriculumEditor__Types

let str = React.string
let t = I18n.t(~scope="components.CurriculumEditor__ContentBlockCreator")
let ts = I18n.ts

module ContentBlockFragment = ContentBlock.Fragment

module CreateMarkdownContentBlock = %graphql(`
    mutation CreateMarkdownContentBlockMutation($targetId: ID!, $aboveContentBlockId: ID) {
      createMarkdownContentBlock(targetId: $targetId, aboveContentBlockId: $aboveContentBlockId) {
        contentBlock {
          ...ContentBlockFragment
        }
      }
    }
  `)

module CreateEmbedContentBlock = %graphql(`
    mutation CreateEmbedContentBlockMutation($targetId: ID!, $aboveContentBlockId: ID, $url: String!, $requestSource: EmbedRequestSource!) {
      createEmbedContentBlock(targetId: $targetId, aboveContentBlockId: $aboveContentBlockId, url: $url, requestSource: $requestSource) {
        contentBlock {
          ...ContentBlockFragment
        }
      }
    }
  `)

module CreateVimeoVideo = %graphql(`
    mutation CreateVimeoVideo($targetId: ID!, $size: Int!, $title: String, $description: String) {
      createVimeoVideo(targetId: $targetId, size: $size, title: $title, description: $description) {
        vimeoVideo {
          link
          uploadLink
        }
      }
    }
  `)

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

    {...state, ui}
  | ToggleSaving => {...state, saving: !state.saving, error: None}
  | FinishSaving(isAboveTarget) => computeInitialState(isAboveTarget)
  | SetError(error) => {...state, error: Some(error)}
  | FailedToCreate => {
      ...state,
      saving: false,
      error: Some(t("failed_create_error")),
    }
  | FailToUpload => {
      ...state,
      saving: false,
      error: Some(t("failed_upload_error")),
    }
  | ShowEmbedForm => {...state, ui: EmbedForm("")}
  | HideEmbedForm => {...state, ui: BlockSelector}
  | ShowUploadVideoForm => {...state, ui: UploadVideo}
  | HideUploadVideoForm => {...state, ui: BlockSelector}
  | UpdateEmbedUrl(url) => {...state, ui: EmbedForm(url)}
  | UpdateVideoTitle(videoTitle) => {...state, videoTitle}
  | UpdateVideoDescription(videoDescription) => {...state, videoDescription}
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
  let variables = CreateMarkdownContentBlock.makeVariables(~targetId, ~aboveContentBlockId?, ())

  CreateMarkdownContentBlock.make(variables)
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

let fileInputId = aboveContentBlock => elementId("markdown-block-file-input-", aboveContentBlock)
let imageInputId = aboveContentBlock => elementId("markdown-block-image-input-", aboveContentBlock)
let videoInputId = aboveContentBlock => elementId("markdown-block-vimeo-input-", aboveContentBlock)
let videoFormId = aboveContentBlock => elementId("markdown-block-vimeo-form-", aboveContentBlock)
let fileFormId = aboveContentBlock => elementId("markdown-block-file-form-", aboveContentBlock)
let imageFormId = aboveContentBlock => elementId("markdown-block-image-form-", aboveContentBlock)
let audioFormId = aboveContentBlock => elementId("markdown-block-audio-form-", aboveContentBlock)
let audioInputId = aboveContentBlock => elementId("markdown-block-audio-input-", aboveContentBlock)

let onBlockTypeSelect = (target, aboveContentBlock, send, addContentBlockCB, blockType, _event) =>
  switch blockType {
  | #Markdown => createMarkdownContentBlock(target, aboveContentBlock, send, addContentBlockCB)
  | #File
  | #Audio
  | #Image => ()
  | #Embed => send(ShowEmbedForm)
  | #VideoEmbed => send(ShowUploadVideoForm)
  }

let button = (target, aboveContentBlock, send, addContentBlockCB, blockType) => {
  let fileId = aboveContentBlock |> fileInputId
  let imageId = aboveContentBlock |> imageInputId
  let videoId = aboveContentBlock |> videoInputId
  let audioId = aboveContentBlock |> audioInputId

  let (faIcon, buttonText, htmlFor) = switch blockType {
  | #Markdown => ("fab fa-markdown", t("button_labels.markdown"), None)
  | #File => ("far fa-file-alt", t("button_labels.file"), Some(fileId))
  | #Image => ("far fa-image", t("button_labels.image"), Some(imageId))
  | #Embed => ("fas fa-code", t("button_labels.embed"), None)
  | #VideoEmbed => ("fab fa-vimeo-v", t("button_labels.video"), Some(videoId))
  | #Audio => ("far fa-file-audio", "Audio", Some(audioId))
  }

  <label
    ?htmlFor
    key=buttonText
    className="px-3 pt-4 pb-3 flex-1 text-center text-primary-500 cursor-pointer border-e last:border-e-0 border-primary-100 hover:bg-primary-100 hover:text-primary-600 transition"
    onClick={onBlockTypeSelect(target, aboveContentBlock, send, addContentBlockCB, blockType)}>
    <i className={faIcon ++ " text-2xl"} />
    <p> {str(buttonText)} </p>
  </label>
}

let embedUrlRegexes = [
  %re("/https:\/\/.*slideshare\.net/"),
  %re("/https:\/\/.*vimeo\.com/"),
  %re("/https:\/\/.*youtube\.com/"),
  %re("/https:\/\/.*youtu\.be/"),
  %re("/https:\/\/docs\.google\.com\/presentation/"),
  %re("/https:\/\/docs\.google\.com\/document/"),
  %re("/https:\/\/docs\.google\.com\/spreadsheets/"),
  %re("/https:\/\/docs\.google\.com\/forms/"),
  %re("/https:\/\/scribehow\.com\/(embed|shared)/"),
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

    let variables = CreateEmbedContentBlock.makeVariables(
      ~targetId,
      ~aboveContentBlockId?,
      ~url,
      ~requestSource,
      (),
    )
    CreateEmbedContentBlock.make(variables)
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
    send(SetError(t("failed_url_error")))
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
  | #Audio
  | #File
  | #Image =>
    Api.sendFormData(
      "/school/targets/" ++ ((target |> Target.id) ++ "/content_block"),
      formData,
      json => {
        Notification.success(ts("notifications.done_exclamation"), t("upload_success_notification"))
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

    let variables = CreateVimeoVideo.makeVariables(
      ~targetId=Target.id(target),
      ~size,
      ~title?,
      ~description?,
      (),
    )

    CreateVimeoVideo.make(variables)
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
  | #Audio => audioFormId(aboveContentBlock)
  }

  let element = ReactDOM.querySelector("#" ++ formId)

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
    | VimeoPlan.Basic => 500.0 *. 1024.0 *. 1024.0
    | Plus
    | Pro
    | Business
    | Premium =>
      5.0 *. 1024.0 *. 1024.0 *. 1024.0
    }
  | None => float_of_int(FileUtils.defaultVideoMaxSize)
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
      switch (FileUtils.isVideo(file), FileUtils.hasValidFloatSize(~maxSize=maxVideoSize, file)) {
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
    | #Audio =>
      switch (FileUtils.isAudio(file), FileUtils.hasValidSize(~maxSize=10 * 1024 * 1024, file)) {
      | (false, true | false) => Some(t("invalid_audio_file_error"))
      | (true, false) => Some(t("audio_upload_size_limit_warning"))
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
  | #Audio => (
      audioInputId(aboveContentBlock),
      audioFormId(aboveContentBlock),
      fileSelectionHandler(#Audio),
      "audio",
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
  <div className="content-block-creator__top-button-container relative">
    <button
      onClick=handler
      id={"top-button-" ++ id}
      title
      ariaLabel={title}
      className="content-block-creator__top-button bg-gray-50 relative rounded-lg border border-gray-500 w-10 h-10 flex justify-center items-center mx-auto z-20 hover:bg-primary-50 hover:text-primary-500 focus:outline-none focus:bg-primary-50 focus:text-primary-500 focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
      <FaIcon classes={"text-base fas " ++ icon} />
    </button>
  </div>

let closeEmbedFormButton = (send, aboveContentBlock) => {
  let id = aboveContentBlock |> OptionUtils.map(ContentBlock.id) |> OptionUtils.default("bottom")

  topButton(_e => send(HideEmbedForm), id, t("close_embed"), "fa-level-up-alt")
}

let closeUploadFormButton = (send, aboveContentBlock) => {
  let id = aboveContentBlock->Belt.Option.mapWithDefault("button", ContentBlock.id)

  topButton(_e => send(HideUploadVideoForm), id, t("close_embed"), "fa-level-up-alt")
}

let toggleVisibilityButton = (send, contentBlock) =>
  topButton(
    _e => send(ToggleVisibility),
    contentBlock |> ContentBlock.id,
    t("toggle_content_block"),
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
        placeholder={t("title_video_placeholder")}
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
        placeholder={t("description_video_placeholder")}
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
    | UploadVideo => t("preparing_upload")
    | BlockSelector
    | EmbedForm(_)
    | Hidden =>
      t("creating")
    }}>
    {uploadFormCurried(#File)}
    {uploadFormCurried(#Image)}
    {uploadFormCurried(#Audio)}
    <div className={containerClasses(state |> visible, isAboveContentBlock)}>
      {buttonAboveContentBlock(state, send, aboveContentBlock)}
      <div className="content-block-creator__inner-container">
        {switch state.ui {
        | Hidden => React.null
        | BlockSelector =>
          <div
            className="content-block-creator__block-content-type text-sm hidden mx-auto relative bg-primary-50 border border-primary-100 rounded-lg -mt-4 overflow-hidden">
            {(
              hasVimeoAccessToken
                ? [#Markdown, #Image, #Embed, #VideoEmbed, #File, #Audio]
                : [#Markdown, #Image, #Embed, #File, #Audio]
            )
            |> Array.map(button(target, aboveContentBlock, send, addContentBlockCB))
            |> React.array}
          </div>
        | UploadVideo =>
          <div
            className="flow-root border-2 border-gray-300 bg-gray-50 border-dashed rounded-lg px-3 pb-3 pt-2 -mt-4 z-10">
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
            className="flow-root border-2 border-gray-300 bg-gray-50 border-dashed rounded-lg px-3 pb-3 pt-2 -mt-4 z-10">
            <label htmlFor=embedInputId className="text-xs font-semibold">
              {t("embed_url.label")->str}
            </label>
            <HelpIcon className="ms-2 text-xs" link={t("embed_url.help_url")}>
              {t("embed_url.help")->str}
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
                className="ms-2 btn btn-success"
                onClick={onEmbedFormSave(target, aboveContentBlock, url, send, addContentBlockCB)}>
                {t("embed_url.save_button")->str}
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
