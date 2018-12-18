import React from "react";
import PropTypes from "prop-types";

export default class TextAreaCounter extends React.Component {
  counterClasses() {
    let classes = "timeline-builder__textarea-counter";

    if (this.textCount() === 500) {
      classes += " timeline-builder__textarea-counter--danger";
    } else if (this.textCount() > 400) {
      classes += " timeline-builder__textarea-counter--warning";
    }

    return classes;
  }

  textCount() {
    let text = this.props.description.trim();
    return text ? this.byteCount(text) : 0;
  }

  byteCount(string) {
    return encodeURI(string).split(/%..|./).length - 1;
  }

  counterText() {
    return this.textCount() + "/500";
  }

  render() {
    return (
      <div className="timeline-builder__textarea-counter-container m-3 position-absolute">
        {this.counterText() !== "" && (
          <div className={this.counterClasses()}>{this.counterText()}</div>
        )}
      </div>
    );
  }
}

TextAreaCounter.propTypes = {
  description: PropTypes.string
};
