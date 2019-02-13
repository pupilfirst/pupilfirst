import React from "react";
import PropTypes from "prop-types";

export default class FounderBubble extends React.Component {
  constructor(props) {
    super(props);
    this.showTooltip = this.showTooltip.bind(this);
  }

  showTooltip(event) {
    let element = $(event.target.closest("a"));
    element.tooltip({
      title: this.props.name + " is yet to pass this target!"
    });
  }

  hideTooltip(event) {
    let element = $(event.target.closest("a"));
    element.tooltip("dispose");
  }

  render() {
    return (
      <a
        className="founder-dashboard__avatar-wrapper"
        onMouseEnter={this.showTooltip}
        onMouseLeave={this.hideTooltip}
      >
        <div className="founder-dashboard__avatar-check">
          <i className={"fa fa-exclamation-circle alert-text"} />
        </div>

        <span dangerouslySetInnerHTML={{ __html: this.props.avatar }} />
      </a>
    );
  }
}

FounderBubble.propTypes = {
  name: PropTypes.string,
  avatar: PropTypes.string
};
