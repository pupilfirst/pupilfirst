class TimelineBuilderTextAreaCounter extends React.Component {
  constructor(props) {
    super(props);
  }

  counterClasses() {
    let classes = 'timeline-builder-social-bar__textarea-counter';

    if (this.textCount() == 300) {
      classes += " timeline-builder-social-bar__textarea-counter--danger";
    } else if (this.textCount() > 200) {
      classes += " timeline-builder-social-bar__textarea-counter--warning";
    }

    return classes;
  }

  textCount() {
    let text = this.props.description.trim();
    return (text ? this.byteCount(text) : 0);
  }

  byteCount(string) {
    return encodeURI(string).split(/%..|./).length - 1;
  }

  counterText() {
    if (this.textCount() == 0) {
      return '';
    } else {
      let text = this.textCount() + "/300";
      return text;
    }
  }

  render() {
    return(
      <div>
        { this.counterText() != '' &&
        <div className={ this.counterClasses() }>{ this.counterText() }</div>
        }
      </div>
    );
  }
}

TimelineBuilderTextAreaCounter.propTypes = {
  description: React.PropTypes.string
};
