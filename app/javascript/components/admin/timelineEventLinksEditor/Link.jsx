import React from "react";
import PropTypes from "prop-types";

export default class Link extends React.Component {
  constructor(props) {
    super(props);

    this.deleteLink = this.deleteLink.bind(this);
    this.editLinkClicked = this.editLinkClicked.bind(this);
  }

  deleteLink() {
    //handle passed all the way from linkEditor
    this.props.deleteLinkCB(this.props.index);
  }

  editLinkClicked() {
    //handle passed all the way from linkEditor
    this.props.editLinkClickedCB(this.props.index);
  }

  render() {
    return (
      <tr className="row">
        <th>
          <i
            className={this.props.private ? "fa fa-user-secret" : "fa fa-globe"}
          />
          &nbsp;{this.props.title}
        </th>
        <td>
          <a href={this.props.url} target="_blank">
            {this.props.url}
          </a>
          &nbsp;(<a onClick={this.editLinkClicked}>Edit</a> /{" "}
          <a onClick={this.deleteLink}>Delete</a>)
        </td>
      </tr>
    );
  }
}

Link.propTypes = {
  title: PropTypes.string,
  url: PropTypes.string,
  private: PropTypes.bool
};
