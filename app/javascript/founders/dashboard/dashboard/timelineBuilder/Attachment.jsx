import React from "react";
import PropTypes from "prop-types";

export default class Attachment extends React.Component {
  constructor(props) {
    super(props);

    this.removeAttachment = this.removeAttachment.bind(this);
  }

  iconClasses() {
    let baseClass = "timeline-builder__attachment-icon";

    switch (this.props.attachment.type) {
      case "cover":
        return baseClass + " fa fa-picture-o";
      case "file":
        return baseClass + " fa fa-file-text-o";
      case "link":
        return baseClass + " fa fa-link";
    }
  }

  removeAttachment() {
    this.props.removeAttachmentCB(
      this.props.attachment.type,
      this.props.attachment.index
    );
  }

  render() {
    return (
      <div className="timeline-builder__attachment pull-left mr-2 mt-2">
        {this.props.attachment.private && (
          <div className="timeline-builder__attachment-private-indicator">
            <i className="fa fa-lock" />
          </div>
        )}
        <i className={this.iconClasses()} />
        <span className="timeline-builder__attachment-title">
          {this.props.attachment.title}
        </span>
        <button
          type="button"
          className="close timeline-builder__remove-attachment"
          onClick={this.removeAttachment}
        >
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    );
  }
}

Attachment.propTypes = {
  attachment: PropTypes.object,
  removeAttachmentCB: PropTypes.func
};
