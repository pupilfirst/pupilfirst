type useAudioRecorder = {
  url: string,
  recording: bool,
  startRecording: unit => unit,
  stopRecording: unit => unit,
  id: string,
}
@bs.module("./navigator")
external useAudioRecorder: (string, bool => unit) => useAudioRecorder = "useAudioRecorder"

@react.component
let make = (~attachingCB, ~attachFileCB) => {
  let audioRecorder = useAudioRecorder(AuthenticityToken.fromHead(), attachingCB)
  React.useEffect1(() => {
    if audioRecorder.id != "" {
      Js.log(("id", audioRecorder.id))
      attachFileCB(audioRecorder.id, "recorderaudio")
    }
    None
  }, [audioRecorder.id])
  <>
    {audioRecorder.recording
      ? <div className="flex pointer-cursor pt-2 items-center">
          <button
            className="flex items-center bg-gray-200 border rounded-full hover:bg-gray-300"
            onClick={_e => audioRecorder.stopRecording()}>
            <div
              className="flex items-center justify-center bg-red-600 shadow-md rounded-full h-10 w-10">
              <Icon className="if i-stop-solid text-base text-white relative z-10" />
              <span
                className="w-8 h-8 z-0 animate-ping absolute inline-flex rounded-full bg-red-600 opacity-75"
              />
            </div>
            <span className="inline-block pl-3 pr-4 text-xs font-semibold">
              {React.string("Recording...")}
            </span>
          </button>
        </div>
      : <div className="flex pointer-cursor pt-2 items-center">
          <button
            className="flex items-center bg-red-100 border rounded-full hover:bg-red-200"
            onClick={_e => audioRecorder.startRecording()}>
            <div
              className="flex items-center justify-center bg-white shadow-md rounded-full h-10 w-10">
              <Icon className="if i-microphone-fill-light text-lg text-red-600" />
            </div>
            <span className="inline-block pl-3 pr-4 text-xs font-semibold">
              {React.string("Start Recording")}
            </span>
          </button>
          {switch audioRecorder.url {
          | "" => React.null
          | src => <audio src controls=true className="pl-4" />
          }}
        </div>}
  </>
}
