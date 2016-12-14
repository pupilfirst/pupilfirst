const TimelineBuilder = React.createClass({
  getInitialState: function () {
    return {
      links: [],
      files: [],
      cover_image: null,
      showLinkAdder: false,
      showFileAdder: false
    }
  },

  showAdder: function (type) {
    if (type == 'link') {
      this.setState({showLinkAdder: true, showFileAdder: false});
    } else {
      this.setState({showLinkAdder: false, showFileAdder: true});
    }
  },

  activeAdder: function () {
    if (this.state.showLinkAdder) {
      return 'link'
    } else if (this.state.showFileAdder) {
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

        { this.state.showLinkAdder &&
        <TimelineBuilderLinkAdder/>
        }

        { this.state.showFileAdder &&
        <TimelineBuilderFileAdder/>
        }

        <TimelineBuilderActionBar adderClickedCB={ this.showAdder } activeAdder={ this.activeAdder() }/>
      </div>
    )
  }
});
