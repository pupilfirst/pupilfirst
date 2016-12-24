const TimelineBuilderTextArea = React.createClass({
  propTypes: {
    hasError: React.PropTypes.bool
  },

  getInitialState: function () {
    return {
      hasError: this.props.hasError
    };
  },

  componentWillReceiveProps: function(newProps) {
    this.setState({hasError: newProps.hasError});
  },

  clearError: function () {
    this.setState({hasError: false});
  },

  componentDidUpdate: function () {
    if (this.state.hasError) {
      $('.js-timeline-builder__textarea').popover('show');
    } else {
      $('.js-timeline-builder__textarea').popover('hide');
    }
  },

  render: function () {
    return (
      <textarea className="form-control js-timeline-builder__textarea timeline-builder__textarea" rows="4"
                placeholder="What&rsquo;s been happening?"  data-toggle="popover" data-title="Description Missing!" data-content="Please add a summary describing the event." data-placement="bottom" onClick={ this.clearError }/>
    )
  }
});
