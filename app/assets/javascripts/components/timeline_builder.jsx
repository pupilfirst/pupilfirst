const TimelineBuilder = React.createClass({
  getInitialState: function () {
    return {
      links: [],
      files: [],
      cover_image: null,
      showLinkForm: false,
      showFileForm: false,
      previousForm: null
    }
  },

  toggleForm: function (type) {
    let previousForm = this.currentForm();

    if (type == 'link') {
      let newState = !this.state.showLinkForm;
      this.setState({showLinkForm: newState, showFileForm: false, previousForm: previousForm});
    } else {
      let newState = !this.state.showFileForm;
      this.setState({showLinkForm: false, showFileForm: newState, previousForm: previousForm});
    }
  },

  currentForm: function () {
    if (this.state.showLinkForm) {
      return 'link'
    } else if (this.state.showFileForm) {
      return 'file'
    } else {
      return null
    }
  },

  hasAttachments: function () {
    return this.state.links.length > 0 || this.state.files.length > 0 || this.state.cover_image != null
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea/>

        { this.hasAttachments() &&
        <TimelineBuilderAttachments/>
        }

        <TimelineBuilderAttachmentForm currentForm={ this.currentForm() } previousForm={ this.state.previousForm }/>
        <TimelineBuilderActionBar formClickedCB={ this.toggleForm } currentForm={ this.currentForm() }/>
      </div>
    )
  }
});
