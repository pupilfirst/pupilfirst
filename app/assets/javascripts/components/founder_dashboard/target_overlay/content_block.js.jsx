class TargetOverlayContentBlock extends React.Component {
  constructor(props) {
    super(props);
    this.prerequisteLinks = this.prerequisteLinks.bind(this);
    this.hasPendingPrerequisites = this.hasPendingPrerequisites.bind(this);
  }

  prerequisteLinks() {
    return this.props.target.prerequisites.map( function (targetDetail) {
        return(
          <li className="target-overlay-content-block__prerequisites-list-item" key={ targetDetail[0] }>
            <a target='_blank' href={"/founder/dashboard/targets/" + targetDetail[0]}>
              { targetDetail[1] }
            </a>
          </li>
        );
      }
    )
  }

  hasPendingPrerequisites() {
    return this.props.target.status === 'unavailable' && !!this.props.target.prerequisites;
  }

  render() {
    return (
      <div className="target-overlay-content-block">

        { this.hasPendingPrerequisites() &&
        <div className="target-overlay-content-block__prerequisites p-a-1 m-b-2">
          <h6 className="font-semibold m-b-1">Pending Prerequisites:</h6>
          <ol className="target-overlay-content-block__prerequisites-list m-b-0">
            { this.prerequisteLinks() }
          </ol>
        </div>
        }

        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.targetDescription }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Description</h5>
        </div>
        <div className="target-overlay-content-block__body target-overlay-content-block__body--description p-b-1">
          <p className="font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>

          { this.props.target.has_rubric &&
          <a className="target-overlay__link m-t-1" target='_blank' href={'/targets/' + this.props.target.id + '/download_rubric'}>
            <span className="target-overlay__link-icon">
              <i className="fa fa-download"/>
            </span>
            <span className="target-overlay__link-text">Download Rubric</span>
          </a>
          }
        </div>

        { this.props.target.completion_instructions &&
        <div>
          <div className="target-overlay-content-block__header p-b-1 clearfix">
            <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.completionInstruction }/>
            <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Completion Instruction</h5>
          </div>
          <div className="target-overlay-content-block__body target-overlay-content-block__body--description p-b-1">
            <p className="font-light">{ this.props.target.completion_instructions }</p>
          </div>
        </div>
        }

        { this.props.target.resource_url &&
          <div>
            <div className="target-overlay-content-block__header p-b-1 clearfix">
              <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.resourceLinks }/>
              <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Resource Link</h5>
            </div>
            <div className="target-overlay-content-block__body">
              <a className="target-overlay__link m-r-1 m-b-1" target='_blank' href={ this.props.target.resource_url }>
                <span className="target-overlay__link-icon">
                  <i className="fa fa-external-link"/>
                </span>
                <span className="target-overlay__link-text">Journey Deck Template</span>
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
