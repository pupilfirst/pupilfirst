import React from 'react';
import CSVReader from 'react-csv-reader'

export default function Reader(props) {
  return (
    <CSVReader
      onFileLoaded={props.onFileLoaded}
      cssClass={props.cssClass}
      onError={props.onError}
      parserOptions={props.parserOptions}
      inputStyle={props.inputStyle}
      inputId={props.inputId}
      inputName={props.inputName}
      label={props.label}/>
  );
};
