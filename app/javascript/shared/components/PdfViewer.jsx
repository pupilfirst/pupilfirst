import React from "react";
import pdfjs from "pdfjs-dist";
import pdfjsWorker from "pdfjs-dist/build/pdf.worker.entry";

pdfjs.GlobalWorkerOptions.workerSrc = pdfjsWorker;

import { Viewer } from "@react-pdf-viewer/core";
import "@react-pdf-viewer/core/lib/styles/index.css";

export default function PdfViewer(props) {
  return <Viewer fileUrl={props.fileUrl} withCredentials={true} />;
}
