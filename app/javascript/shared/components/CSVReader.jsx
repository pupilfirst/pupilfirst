import React from 'react';
import CSVReader from 'react-csv-reader'

export default function Reader(props) {
  return (
    <CSVReader
      onFileLoaded={props.onFileLoaded} />
  );
};
