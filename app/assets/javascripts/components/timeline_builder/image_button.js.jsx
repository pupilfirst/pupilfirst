class TimelineBuilderImageButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showSizeError: false, showFormatError: false, showDimensionError: false};

    this.handleImageButtonClick = this.handleImageButtonClick.bind(this);
    this.handleImageChange = this.handleImageChange.bind(this);
  }

  componentDidUpdate() {
    if (this.state.showSizeError || this.state.showFormatError || this.state.showDimensionError) {
      $('.image-upload').popover('show');
    } else {
      $('.image-upload').popover('hide');
    }
  }

  handleImageButtonClick() {
    this.setState({showSizeError: false, showFormatError: false, showDimensionError: false});

    if (this.props.coverImage != null) {
      return;
    }

    $('.js-timeline-builder__image-input').trigger('click');
  }

  handleImageChange(event) {
    let inputElement = $(event.target);
    this.validate(inputElement);
  }

  processCoverImage(inputElement) {
    this.moveImageInputToHiddenForm(inputElement);
    this.props.addDataCB('cover');
  }

  validate(inputElement) {
    if (inputElement.val() == '') {
      return;
    }

    let imageFile = inputElement[0].files[0];

    // File size should be < 5 MB.
    if (imageFile.size > 5242880) {
      this.setState({showSizeError: true});
      return false;
    }

    // Restrict to image types.
    let fileName = inputElement.val().split('\\').pop();
    let fileExtension = fileName.match(/\.([^\.]+)$/)[1];

    if ($.inArray(fileExtension.toLowerCase(), ['png', 'jpg', 'jpeg', 'svg']) == (-1)) {
      this.setState({showFormatError: true});
      return false;
    }

    // Restrict dimensions to max 4096x4096.
    let testImage = new Image();
    testImage.src = window.URL.createObjectURL(imageFile);

    testImage.onload = function () {
      let width = testImage.naturalWidth;
      let height = testImage.naturalHeight;

      // Unload the image.
      window.URL.revokeObjectURL(testImage.src);

      if (width > 4096 || height > 4096) {
        this.setState({showDimensionError: true});
        return false;
      } else {
        this.processCoverImage(inputElement)
      }
    }.bind(this);
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

    if (this.props.coverImage != null || this.props.disabled) {
      classes += ' action-tab-disabled'
    }

    return classes
  }

  errorPopoverText() {
    if (this.state.showSizeError) {
      return 'Please select an image less than 5MB in size.'
    } else if (this.state.showFormatError) {
      return 'Only .png, .jpg, .jpeg and .svg files are accepted.'
    } else if (this.state.showDimensionError) {
      return 'Please select an image less than 4096 pixels wide or high.'
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
  coverImage: PropTypes.object,
  addDataCB: PropTypes.func,
  disabled: PropTypes.bool,
};
