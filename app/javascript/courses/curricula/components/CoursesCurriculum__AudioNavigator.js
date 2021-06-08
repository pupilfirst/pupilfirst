import { useState, useRef, useEffect } from "react";
import { error } from "../../../shared/Notification.bs";
import { Blob } from "blob-polyfill";
import { saveAs } from "file-saver";

function audioRecorder(authenticity_token, attachingCB) {
  const [state, setState] = useState({
    recording: false,
    url: undefined,
    blob: undefined,
    id: undefined,
  });

  const mediaStreamRef = useRef();

  useEffect(() => {
    if (state.blob && state.blob.size < 5000000) {
      attachingCB(true);
      const formData = new FormData();
      formData.append("authenticity_token", authenticity_token);
      formData.append("file", state.blob);
      fetch("/timeline_event_files/", {
        method: "POST",
        body: formData,
      })
        .then((res) => res.json())
        .then((res) => {
          setState({ ...state, id: res.id });
        })
        .catch((err) => {
          error("Something went wrong", String(err));
        });
    }
  }, [state.blob]);
  function startRecording() {
    if (
      navigator.mediaDevices &&
      navigator.mediaDevices.getUserMedia &&
      !state.recording
    ) {
      navigator.mediaDevices
        .getUserMedia({
          audio: true,
        })
        .then(function (stream) {
          mediaStreamRef.current = new MediaRecorder(stream);
          const mediaRecorder = mediaStreamRef.current;
          let chunks = [];
          mediaRecorder.ondataavailable = function (e) {
            chunks.push(e.data);
          };
          mediaRecorder.onstop = () => {
            const blob = new Blob(chunks, { type: "audio/ogg; codecs=opus" });
            const audioURL = window.URL.createObjectURL(blob);
            setState({ ...state, blob: blob, url: audioURL, recording: false });
            stream.getTracks().forEach((track) => track.stop());
          };
          setState({ ...state, recording: true });

          mediaRecorder.start();
        })
        .catch(function (err) {
          setRecording(false);
          error(
            "Permission to access microphone not granted.",
            "Allow access to microphone in your browser settings for this domain."
          );
        });
    } else {
      error("Browser does not support recording!");
    }
  }
  return {
    id: state.id,
    url: state.url,
    recording: state.recording,
    blobSize: state.blob?.size,
    startRecording,
    stopRecording: () => {
      if (mediaStreamRef.current) {
        mediaStreamRef.current.stop();
      }
    },
    downloadBlob: () => {
      if (state.blob) {
        saveAs(state.blob, "Recording.mp3");
      }
    },
  };
}
export { audioRecorder };
