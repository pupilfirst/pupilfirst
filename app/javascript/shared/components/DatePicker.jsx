import React from 'react';
import DatePicker from 'react-datepicker';

import "react-datepicker/dist/react-datepicker.css";
import "./DatePicker.css";

export default function Picker(props) {
  return (
    <DatePicker
      id={props.id}
      selected={props.selected}
      onChange={props.onChange}
      wrapperClassName="w-full"
      className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
      placeholderText="YYYY-MM-DD"
      dateFormat="yyyy-MM-dd"
      isClearable />
  );
};
