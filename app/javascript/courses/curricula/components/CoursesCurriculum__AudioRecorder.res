type useAudioRecorder = {
  url: string,
  recording: bool,
  startRecording: unit => unit,
  stopRecording: unit => unit,
  id: string,
}
@bs.module("./navigator")
external useAudioRecorder: (string, bool => unit) => useAudioRecorder = "useAudioRecorder"
@bs.module external audioPauseImage: string = "../images/target-audio-pause-button.svg"
@bs.module external audioRecordImage: string = "../images/target-audio-record-button.svg"

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
      ? <div className="flex flex-row pointer-cursor pt-4 items-center">
          <img
            className="h-14 w-14 pointer-cursor"
            src=audioPauseImage
            onClick={_e => audioRecorder.stopRecording()}
          />
          <span style={ReactDOMStyle.make(~paddingLeft="16px", ())}>
            {React.string("Recording...")}
          </span>
        </div>
      : <div className="flex flex-row pointer-cursor pt-4 items-center">
          <img
            className="h-14 w-14 pointer-cursor"
            src=audioRecordImage
            onClick={_e => audioRecorder.startRecording()}
          />
          {switch audioRecorder.url {
          | "" => React.null
          | src => <audio src controls=true style={ReactDOMStyle.make(~paddingLeft="16px", ())} />
          }}
        </div>}
  </>
}
