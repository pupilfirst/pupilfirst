class TargetOverlayContentBlock extends React.Component {
  render() {
    return (
      <div className="target-overlay-content-block">
        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.targetDescription }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Target Description</h5>
        </div>
        <div className="target-overlay-content-block__description p-b-1">
          <p className="font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>
        </div>

        { this.props.target.slideshow_embed &&
        <div>
          <div className="target-overlay-content-block__header p-b-1 clearfix">
            <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.slideshowEmbed }/>
            <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Presentation</h5>
          </div>
          <div className= "target-overlay-content-block__embed-block p-b-1">
            <div dangerouslySetInnerHTML={ { __html: this.props.target.slideshow_embed } }></div>
          </div>
        </div>
        }

        { this.props.target.video_embed &&
        <div>
          <div className="target-overlay-content-block__header p-b-1 clearfix">
            <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.videoEmbed }/>
            <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Video</h5>
          </div>
          <div className= "target-overlay-content-block__embed-block p-b-1">
            <div dangerouslySetInnerHTML={ { __html: this.props.target.video_embed } }></div>
          </div>
        </div>
        }
      </div>
    );
  }
}

TargetOverlayContentBlock.propTypes = {
  target: React.PropTypes.object,
  iconPaths: React.PropTypes.object
};
