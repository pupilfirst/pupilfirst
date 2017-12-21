import React from "react";
import PropTypes from "prop-types";
import LinkForm from "./timelineEventLinksEditor/LinkForm";
import LinkList from "./timelineEventLinksEditor/LinkList";

export default class TimelineEventLinksEditor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      links:
        this.props.linksJSON.length > 0 ? JSON.parse(this.props.linksJSON) : [],
      showLinkForm: false
    };
  }

  addLinksClicked() {
    this.setState({ showLinkForm: true, showFileForm: false });
  }

  addNewLink(newLink) {
    const linksClone = _.cloneDeep(this.state.links);
    linksClone.push(newLink);
    this.setState({ links: linksClone, showLinkForm: false });
  }

  attachmentsLimitNotReached() {
    return this.state.links.length < 3;
  }

  showAddLinkButton() {
    return this.attachmentsLimitNotReached() && !this.state.showLinkForm;
  }

  deleteLink(i) {
    const linksClone = _.cloneDeep(this.state.links);
    linksClone.splice(i, 1);
    this.setState({ links: linksClone });
  }

  editLinkClicked(i) {
    //clone the object to a new one, else it will be passed by reference
    const linkToEdit = $.extend({}, this.state.links[i]);
    linkToEdit.index = i;
    this.setState({ linkToEdit: linkToEdit, showLinkForm: true });
  }

  editLink(link) {
    const linksClone = _.cloneDeep(this.state.links);
    linksClone[link.index] = {
      title: link.title,
      url: link.url,
      private: link.private
    };
    this.setState({ links: linksClone, showLinkForm: false, linkToEdit: null });
  }

  render() {
    return (
      <div>
        <LinkList
          links={this.state.links}
          deleteLinkCB={this.deleteLink}
          editLinkClickedCB={this.editLinkClicked}
        />

        {this.showAddLinkButton() && (
          <a onClick={this.addLinksClicked} className="button">
            <i className="fa fa-plus" /> Add a link
          </a>
        )}

        {this.state.showLinkForm && (
          <LinkForm
            linkAddedCB={this.addNewLink}
            editLinkCB={this.editLink}
            link={this.state.linkToEdit}
          />
        )}
      </div>
    );
  }
}

TimelineEventLinksEditor.propTypes = {
  linksJSON: PropTypes.string.isRequired
};
