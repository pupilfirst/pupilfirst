import React, { Component } from "react";
import PropTypes from "prop-types";
import "trix";
import "trix/dist/trix.css";

// This is adapted from https://github.com/AndrewGHC/react-trix-editor/blob/master/src/ReactTrixEditor.js
export default class ReactTrixEditor extends Component {
  static propTypes = {
    onChange: PropTypes.func.isRequired,
    autofocus: PropTypes.bool,
    input: PropTypes.string,
    placeholder: PropTypes.string,
    initialValue: PropTypes.string
  };

  static defaultProps = {
    autofocus: false,
    input: "react-trix-editor",
    placeholder: "Enter text here..."
  };

  constructor() {
    super();
    this.id = Math.random().toString(36);
    this.updateStateValue = this.updateStateValue.bind(this);
  }

  componentDidMount() {
    document
      .getElementById(this.id)
      .addEventListener("trix-change", e => this.updateStateValue(e));
  }

  updateStateValue(e) {
    const value = e.target.value;
    this.props.onChange(value);
  }

  render() {
    const { input, initialValue, placeholder, autofocus } = this.props;

    return (
      <div>
        <input id={input} value={initialValue} type="hidden" name="content" />
        <trix-editor
          id={this.id}
          input={input}
          placeholder={placeholder}
          autofocus={autofocus}
        />
      </div>
    );
  }
}
