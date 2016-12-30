class TimelineBuilderImageButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showSizeError: false, showFormatError: false};

    this.handleImageButtonClick = this.handleImageButtonClick.bind(this);
    this.handleImageChange = this.handleImageChange.bind(this);
  }

  componentDidUpdate() {
    if (this.state.showSizeError || this.state.showFormatError) {
      $('.image-upload').popover('show');
    } else {
      $('.image-upload').popover('hide');
    }
  }

  handleImageButtonClick() {
    this.setState({showSizeError: false, showFormatError: false});

    if (this.props.coverImage != null) {
      return;
    }

    $('.js-timeline-builder__image-input').trigger('click');
  }

  handleImageChange(event) {
    let inputElement = $(event.target);

    if (inputElement.val() != '') {
      if (this.validate(inputElement)) {
        this.moveImageInputToHiddenForm(inputElement);
        this.props.addDataCB('cover');
      }
    }
  }

  validate(inputElement) {
    // File size should be < 5 MB.
    if (inputElement[0].files[0].size > 5242880) {
      this.setState({showSizeError: true});
      return false;
    }

    // Restrict to image types.
    let fileName = inputElement.val().split('\\').pop();
    let fileExtension = fileName.match(/\.([^\.]+)$/)[1];

    if ($.inArray(fileExtension, ['png', 'jpg', 'jpeg', 'svg']) == (-1)) {
      this.setState({showFormatError: true});
      return false;
    }

    return true;
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

  errorPopoverText() {
    if (this.state.showSizeError) {
      return 'Please select an image less than 5MB in size.'
    } else if (this.state.showFormatError) {
      return 'Only .png, .jpg, .jpeg and .svg files are accepted.'
    } else {
      return ''
    }
  }

  render() {
    return (
      <div className={ this.actionTabClasses() } onClick={ this.handleImageButtonClick } data-toggle="popover"
           data-title="File Invalid!" data-content={ this.errorPopoverText() } data-placement="bottom"
           data-trigger="manual">
        <label className="sr-only" htmlFor="timeline-builder__image-input">Cover Image</label>
        <input id="timeline-builder__image-input" type="file" onChange={ this.handleImageChange }
               className="js-timeline-builder__image-input hidden-xs-up"
               accept=".png,.jpg,.jpeg,.svg,image/png,image/jpeg,image/pjpeg"/>
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
