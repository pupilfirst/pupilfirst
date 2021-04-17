import { useState, useRef, useEffect } from "react";
function useAudioRecorder(authenticity_token) {
    console.log("started");
    const [recording, setRecording] = useState(false);
    const [url, setUrl] = useState("");
    const mediaStreamRef = useRef();
    const [blob, setBlob] = useState();
    const [id, setId] = useState("");
    useEffect(() => {
        if (blob) {
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
                .catch((err) => console.log(err));
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
                        console.log(mediaStreamRef.current);
                        const blob = new Blob(chunks, { type: "audio/ogg; codecs=opus" });
                        setBlob(blob);
                        const audioURL = window.URL.createObjectURL(blob);
                        setUrl(audioURL);
                        setRecording(false);
                    };
                    setRecording(true);

                    mediaRecorder.start();
                })

                // Error callback
                .catch(function (err) {
                    setRecording(false);
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