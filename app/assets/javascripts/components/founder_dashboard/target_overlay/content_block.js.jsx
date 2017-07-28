class TargetOverlayContentBlock extends React.Component {
  render() {
    return (
      <div className="target-overlay-content-block">
        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.targetDescription }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Target Description</h5>
        </div>
        <div className="target-overlay-content-block__body target-overlay-content-block__body--description p-b-1">
          <p className="font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>

          { this.props.target.has_rubric &&
          <a className="target-overlay-content-block__link m-t-1" target='_blank' href={'/targets/' + this.props.target.id + '/download_rubric'}>
            <span className="target-overlay-content-block__link-icon">
              <i className="fa fa-download"/>
            </span>
            <span className="target-overlay-content-block__link-text">&nbsp;Download Rubric</span>
          </a>
          }

        </div>

        { this.props.target.resource_url &&
          <div>
            <div className="target-overlay-content-block__header p-b-1 clearfix">
              <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.resourceLinks }/>
              <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Resource Link</h5>
            </div>
            <div className="target-overlay-content-block__body">
              <a className="target-overlay-content-block__link m-r-1 m-b-1" target='_blank' href={ this.props.target.resource_url }>
                <span className="target-overlay-content-block__link-icon">
                  <i className="fa fa-external-link"/>
                </span>
                <span className="target-overlay-content-block__link-text">&nbsp;Journey Deck Template</span>
              </a>
            </div>
          </div>
        }


        { this.props.target.slideshow_embed &&
        <div>
          <div className="target-overlay-content-block__header p-b-1 clearfix">
            <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.slideshowEmbed }/>
            <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Presentation</h5>
          </div>
          <div className= "target-overlay-content-block__body target-overlay-content-block__body--embed-block p-b-1">
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
          <div className= "target-overlay-content-block__body target-overlay-content-block__body--embed-block p-b-1">
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
