const TimelineBuilderTextArea = React.createClass({
  getInitialState: function () {
    return null;
  },

  render: function () {
    return (
      <textarea className="form-control" id="timelineTextarea" rows="3" placeholder="What&rsquo;s been happening?"/>
    )
  }
});
