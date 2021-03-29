import React from 'react';
import { Worker, Viewer } from '@react-pdf-viewer/core';
import '@react-pdf-viewer/core/lib/styles/index.css';

export default function PdfViewer(props) {
  return (
    <Worker workerUrl="pdf.worker.js">
      <Viewer fileUrl={props.fileUrl} withCredentials={true} />
    </Worker>
  )
}
