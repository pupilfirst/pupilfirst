const TimelineBuilder = React.createClass({
  getInitialState: function () {
    return {
      links: [],
      files: [],
      showLinkAdder: false,
      showFileAdder: false
    }
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea/>
        <TimelineBuilderAttachments/>
        <TimelineBuilderLinkAdder/>
        <TimelineBuilderFileAdder/>
        <TimelineBuilderActionBar/>
      </div>
    )
  }
});
