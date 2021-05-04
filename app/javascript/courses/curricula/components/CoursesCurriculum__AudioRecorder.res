type audioRecorder = {
  url: string,
  recording: bool,
  startRecording: unit => unit,
  stopRecording: unit => unit,
  id: string,
}
@bs.module("./navigator")
external audioRecorder: (string, bool => unit) => audioRecorder = "useAudioRecorder"
@bs.module external audioPauseImage: string = "../images/target-audio-pause-button.svg"
@bs.module external audioRecordImage: string = "../images/target-audio-record-button.svg"

@react.component
let make = (~attachingCB, ~attachFileCB) => {
  let audioRecorder = audioRecorder(AuthenticityToken.fromHead(), attachingCB)
  React.useEffect1(() => {
    if audioRecorder.id != "" {
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
          <span className="pl-4"> {React.string("Recording...")} </span>
        </div>
      : <div className="flex flex-row pointer-cursor pt-4 items-center">
          <img
            className="h-14 w-14 pointer-cursor"
            src=audioRecordImage
            onClick={_e => audioRecorder.startRecording()}
          />
          {switch audioRecorder.url {
          | "" => React.null
          | src => <audio src controls=true className="pl-4" />
          }}
        </div>}
  </>
}
