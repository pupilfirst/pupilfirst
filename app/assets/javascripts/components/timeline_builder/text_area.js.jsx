const TimelineBuilderTextArea = React.createClass({
  getInitialState: function () {
    return null;
  },

  render: function () {
    return (
      <textarea className="form-control timeline-builder__textarea" rows="4" placeholder="What&rsquo;s been happening?"/>
    )
  }
});
