import React from "react";
import PropTypes from "prop-types";
import Link from "./Link";

export default class LinkList extends React.Component {
  componentDidUpdate() {
    // Always copy latest links to the hidden field, trigger change to update the link tab's title.
    $("#timeline_event_serialized_links")
      .val(JSON.stringify(this.props.links))
      .trigger("change");
  }

  render() {
    if (this.props.links.length > 0) {
      return (
        <div className="attributes_table">
          <table>
            <tbody>
              {this.props.links.map(
                function(link, i) {
                  return (
                    <Link
                      title={link.title}
                      url={link.url}
                      private={link.private}
                      index={i}
                      editLinkClickedCB={this.props.editLinkClickedCB}
                      deleteLinkCB={this.props.deleteLinkCB}
                      key={link.title + link.url}
                    />
                  );
                }.bind(this)
              )}
            </tbody>
          </table>
        </div>
      );
    } else {
      return <div />;
    }
  }
}

LinkList.propTypes = {
  links: PropTypes.arrayOf(PropTypes.object),
  editLinkClickedCB: PropTypes.func.isRequired,
  deleteLinkCB: PropTypes.func.isRequired
};
