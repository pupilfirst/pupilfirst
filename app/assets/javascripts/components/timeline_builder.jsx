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

  toggleAdder: function (type) {
    if (type == 'link') {
      let newState = !this.state.showLinkAdder;
      this.setState({showLinkAdder: newState, showFileAdder: false});
    } else {
      let newState = !this.state.showFileAdder;
      this.setState({showLinkAdder: false, showFileAdder: newState});
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

        <React.addons.CSSTransitionGroup
          transitionName="timeline-builder-adder"
          transitionEnterTimeout={500}
          transitionLeaveTimeout={300}>

          { this.state.showLinkAdder &&
          <TimelineBuilderLinkAdder key="1"/>
          }

          { this.state.showFileAdder &&
          <TimelineBuilderFileAdder key="1"/>
          }
        </React.addons.CSSTransitionGroup>

        <TimelineBuilderActionBar adderClickedCB={ this.toggleAdder } activeAdder={ this.activeAdder() }/>
      </div>
    )
  }
});
