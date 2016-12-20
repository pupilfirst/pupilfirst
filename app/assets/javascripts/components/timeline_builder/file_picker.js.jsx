class TimelineBuilderFilePicker extends React.Component {
  constructor(props) {
    super(props);

    this.state = {fileLabel: ''};
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    let fileName = $(event.target).val().split('\\').pop();
    let newLabelText = fileName ? fileName : '';
    this.setState({fileLabel: newLabelText});
  }

  render() {
    return (
      <div className="form-group file-choose-group">
        <input type="file" className="form-control-file file-choose js-attachment-file"
               id="timeline-builder__file-input" onChange={ this.handleChange }/>
        <label htmlFor="timeline-builder__file-input">
          <span>{ this.state.fileLabel }</span>
          <div className="choose-file-btn">
            <i className="fa fa-upload"/>
            CHOOSE FILE
          </div>
        </label>
      </div>
    )
  }
}
