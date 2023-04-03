type audioRecorderControls = {
  url: option<string>,
  recording: bool,
  blobSize: option<int>,
  startRecording: unit => unit,
  stopRecording: unit => unit,
  downloadBlob: unit => unit,
  id: option<string>,
}
let str = React.string
@module("./CoursesCurriculum__AudioNavigator")
external audioRecorder: (string, bool => unit) => audioRecorderControls = "audioRecorder"
let t = I18n.t(~scope="components.CoursesCurriculum__AudioRecorder")

@react.component
let make = (~attachingCB, ~attachFileCB, ~preview) => {
  let audioRecorder = audioRecorder(AuthenticityToken.fromHead(), attachingCB)
  React.useEffect1(() => {
    switch audioRecorder.id {
    | Some(id) => attachFileCB(id, "recorderaudio")
    | None => ()
    }
    None
  }, [audioRecorder.id])
  <>
    {audioRecorder.recording
      ? <div className="flex flex-col md:flex-row pointer-cursor pt-2 md:items-center">
          <button
            className="flex items-center bg-gray-50 border rounded-full hover:bg-gray-300"
            onClick={_e => audioRecorder.stopRecording()}>
            <div
              className="flex shrink-0 items-center justify-center bg-red-600 shadow-md rounded-full h-10 w-10">
              <Icon className="if i-stop-solid text-base text-white relative z-10" />
              <span
                className="w-8 h-8 z-0 animate-ping absolute inline-flex rounded-full bg-red-600 opacity-75"
              />
            </div>
            <span className="inline-block ps-3 pe-4  text-xs font-semibold">
              {str(t("recording_string"))}
            </span>
          </button>
        </div>
      : <div className="flex flex-col md:flex-row pointer-cursor pt-2 md:items-center">
          <button
            className="flex items-center bg-red-100 border rounded-full hover:bg-red-200"
            onClick={_e =>
              preview
                ? Notification.notice(t("preview_mode"), t("cannot_record"))
                : audioRecorder.startRecording()}>
            <div
              className="flex shrink-0 items-center justify-center bg-white shadow-md rounded-full h-10 w-10">
              <Icon className="if i-microphone-fill-light text-lg text-red-600" />
            </div>
            <span className="inline-block ps-3 pe-4  text-xs font-semibold">
              {str({
                switch audioRecorder.url {
                | Some(_url) => t("button_text_record_again")
                | None => t("button_text_start_recording")
                }
              })}
            </span>
          </button>
          {switch audioRecorder.url {
          | None => React.null
          | Some(url) => <audio src={url} controls=true className="pt-3 md:pt-0 md:ps-4" />
          }}
          {switch audioRecorder.url {
          | None => React.null
          | Some(_) =>
            <div className="btn btn-success ms-4" onClick={_e => audioRecorder.downloadBlob()}>
              <FaIcon classes="fas fa-download" />
            </div>
          }}
        </div>}
    {switch audioRecorder.blobSize {
    | None => React.null
    | Some(size) =>
      size > 5000000
        ? <div className="text-xs text-red-500 mt-2">
            <FaIcon classes="fas fa-exclamation-triangle me-2" />
            {str(t("recording_size_limit_warning"))}
          </div>
        : React.null
    }}
  </>
}
