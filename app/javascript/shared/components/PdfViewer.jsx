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

  function goToPage(number) {
    const parsed = number && parseInt(number);
    console.log({number, parsed, numPages, pageNumber});
    parsed
      && parsed >= 1
      && parsed <= numPages
      && parsed != pageNumber
      && setPageNumber(parsed)
  }

  return (
    <div className="flex flex-col items-center">
      { (numPages || 1) > 1 &&
      <div className="flex flex-row items-center mb-2">
        <button type="button" className="transparent-background"
          disabled={pageNumber <= 1} onClick={previousPage}>
          <i className="fas fa-arrow-left"></i>
        </button>
        <span className="pl-4">
          Page
        </span>
        <input
          type="number" id="quantity" name="page"
          min={1} max={numPages || 1}
          value={pageNumber || 1}
          className="no-arrows mx-2 px-1 border border-gray-300 text-center"
          onChange={e => goToPage(e.target.value)}
        />
        <span className="pr-4">
          of {numPages || '--'}
        </span>
        <button type="button" className="transparent-background"
          disabled={pageNumber >= numPages} onClick={nextPage}>
          <i className="fas fa-arrow-right"></i>
        </button>
      </div>}
      <Document
        file={props.url}
        onLoadSuccess={onDocumentLoadSuccess}
        options={options}
      >
        <Page pageNumber={pageNumber} />
      </Document>
    </div>
  );
}
