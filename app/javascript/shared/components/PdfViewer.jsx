import React, { useState } from 'react';
import { Document, Page } from 'react-pdf/dist/esm/entry.webpack';
import 'react-pdf/dist/esm/Page/AnnotationLayer.css';
import "./PdfViewer.css";

const options = {
  cMapUrl: 'cmaps/',
  cMapPacked: true,
};

export default function PdfViewer(props) {
  const [numPages, setNumPages] = useState(null);
  const [pageNumber, setPageNumber] = useState(1);

  function onDocumentLoadSuccess({ numPages: nextNumPages }) {
    setNumPages(nextNumPages);
    setPageNumber(1);
  }

  function changePage(offset) {
    setPageNumber(prevPageNumber => prevPageNumber + offset);
  }

  function previousPage() {
    changePage(-1);
  }

  function nextPage() {
    changePage(1);
  }

  return (
    <div className="flex flex-col items-center">
      <Document
        file={props.url}
        onLoadSuccess={onDocumentLoadSuccess}
        options={options}
      >
        <Page pageNumber={pageNumber} />
      </Document>
      { (numPages || 1) > 1 &&
      <div className="flex flex-row items-center mt-2">
        <button type="button" className="disabled:bg-transparent"
          disabled={pageNumber <= 1} onClick={previousPage}>
          <i className="fas fa-arrow-left"></i>
        </button>
        <span className="px-4">
          Page {pageNumber || (numPages ? 1 : '--')} of {numPages || '--'}
        </span>
        <button type="button" className="disabled:bg-transparent"
          disabled={pageNumber >= numPages} onClick={nextPage}>
          <i className="fas fa-arrow-right"></i>
        </button>
      </div>}
    </div>
  );
}
