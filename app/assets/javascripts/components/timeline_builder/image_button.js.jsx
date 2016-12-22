class TimelineBuilderImageButton extends React.Component {
  constructor(props) {
    super(props);

    this.handleImageButtonClick = this.handleImageButtonClick.bind(this);
    this.handleImageChange = this.handleImageChange.bind(this);
  }

  handleImageButtonClick() {
    if (this.props.coverImage != null) {
      return
    }

    $('.js-timeline-builder__image-input').trigger('click');
  }

  handleImageChange(event) {
    let inputElement = $(event.target);
    let fileName = inputElement.val().split('\\').pop();

    if (fileName.length > 0) {
      this.moveImageInputToHiddenForm(inputElement);
      this.props.addDataCB('cover')
    }
  }

  moveImageInputToHiddenForm(originalInput) {
    let clonedInput = originalInput.clone();
    let hiddenForm = $('.timeline-builder-hidden-form');

    // Place a clone after the original input, and move the original into the hidden form.
    originalInput.after(clonedInput).appendTo(hiddenForm);

    // Prep the original input for submission.
    originalInput.removeAttr('class');
    originalInput.attr('name', 'timeline_event[image]');
  }

  actionTabClasses() {
    let classes = 'timeline-builder__upload-section-tab image-upload';

    if (this.props.coverImage != null) {
      classes += ' action-tab-disabled'
    }

    return classes
  }

  render() {
    return (
      <div className={ this.actionTabClasses() } onClick={ this.handleImageButtonClick }>
        <input type="file" onChange={ this.handleImageChange } className="js-timeline-builder__image-input hidden-xs-up"/>
        <i className="timeline-builder__upload-section-icon fa fa-file-image-o"/>
        <span className="timeline-builder__tab-label">Image</span>
      </div>
    )
  }
}

TimelineBuilderImageButton.propTypes = {
  coverImage: React.PropTypes.object,
  addDataCB: React.PropTypes.func
};
