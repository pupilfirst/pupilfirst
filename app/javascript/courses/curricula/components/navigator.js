import { useState, useRef, useEffect } from "react";
import { error } from "../../../shared/Notification.bs"
function useAudioRecorder(authenticity_token,attachingCB) {
    const [recording, setRecording] = useState(false);
    const [url, setUrl] = useState("");
    const mediaStreamRef = useRef();
    const [blob, setBlob] = useState();
    const [id, setId] = useState("");
    useEffect(() => {
        if (blob) {
            attachingCB(true)
            const formData = new FormData();
            formData.append("authenticity_token", authenticity_token);
            console.log({ blob });
            formData.append("file", blob);
            fetch("/timeline_event_files/", {
                method: "POST",
                body: formData,
            })
                .then((res) => res.json())
                .then((res) => {
                    setId(res.id);
                })
                .catch((err) => {
                    error("Something went wrong", String(err))
                });
        }
    }, [blob]);
    function startRecording() {
        if (
            navigator.mediaDevices &&
            navigator.mediaDevices.getUserMedia &&
            !recording
        ) {
            navigator.mediaDevices
                .getUserMedia(
                    // constraints - only audio needed for this app
                    {
                        audio: true,
                    }
                )

                // Success callback
                .then(function (stream) {
                    mediaStreamRef.current = new MediaRecorder(stream);
                    const mediaRecorder = mediaStreamRef.current;
                    let chunks = [];
                    mediaRecorder.ondataavailable = function (e) {
                        chunks.push(e.data);
                    };
                    mediaRecorder.onstop = () => {
                        const blob = new Blob(chunks, { type: "audio/ogg; codecs=opus" });
                        setBlob(blob);
                        const audioURL = window.URL.createObjectURL(blob);
                        setUrl(audioURL);
                        setRecording(false);
                        stream.getTracks().forEach(track => track.stop());
                    };
                    setRecording(true);

                    mediaRecorder.start();
                })

                // Error callback
                .catch(function (err) {
                    setRecording(false);
                    error("Permission Denied", String(err))
                    console.log("The following getUserMedia error occured: " + err);
                });
        } else {
            console.log("getUserMedia not supported on your browser!");
            alert("Browser does not support recording");
        }
    }
    return {
        id,
        url,
        recording,
        startRecording,
        stopRecording: () => {
            if (mediaStreamRef.current) {
                mediaStreamRef.current.stop();
            }
        },
    };
}
export { useAudioRecorder };