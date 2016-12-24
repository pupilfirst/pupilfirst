class TimelineBuilderTextArea extends React.Component {
  constructor(props) {
    super(props);

    this.handleChange = this.handleChange.bind(this)
  }

  componentDidUpdate() {
    if (this.props.showError) {
      $('.js-timeline-builder__textarea').popover('show');
    } else {
      $('.js-timeline-builder__textarea').popover('hide');
    }
  }

  handleChange() {
    this.props.resetErrorsCB();
  }

  render() {
    return (
      <textarea className="form-control js-timeline-builder__textarea timeline-builder__textarea" rows="4"
                placeholder="What&rsquo;s been happening?" data-toggle="popover" data-title="Description Missing!"
                data-content="Please add a summary describing the event." data-placement="bottom" data-trigger="manual"
                onFocus={ this.handleChange }/>
    )
  }
}

TimelineBuilderTextArea.propTypes = {
  showError: React.PropTypes.bool,
  resetErrorsCB: React.PropTypes.func
};
