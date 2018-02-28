import React from "react";
import PropTypes from "prop-types";

export default class ContentBlock extends React.Component {
  constructor(props) {
    super(props);
    this.prerequisiteLinks = this.prerequisiteLinks.bind(this);
    this.hasPendingPrerequisites = this.hasPendingPrerequisites.bind(this);
    this.resourceLinks = this.resourceLinks.bind(this);
    this.rubricButtonText = this.rubricButtonText.bind(this);
  }

  prerequisiteLinks() {
    const that = this;

    return this.props.target.prerequisites.map(function(prerequisiteTarget) {
      const target = _.find(that.props.rootProps.targets, [
        "id",
        prerequisiteTarget.id
      ]);

      return (
        <li
          className="target-overlay-content-block__prerequisites-list-item"
          key={target.id}
        >
          <a target="_blank" href={"/student/dashboard/targets/" + target.id}>
            {target.title}
          </a>
        </li>
      );
    });
  }

  resourceLinks() {
    return this.props.linkedResources.map(function(resourceDetail) {
      return (
        <a
          className="target-overlay__link mr-2 mb-3"
          key={resourceDetail.id}
          target="_blank"
          href={"/library/" + resourceDetail.slug}
        >
          <span className="target-overlay__link-icon">
            <i className="fa fa-external-link" />
          </span>
          <span className="target-overlay__link-text">
            {resourceDetail.title}
          </span>
        </a>
      );
    });
  }

  hasPendingPrerequisites() {
    return (
      this.props.target.status === "unavailable" &&
      this.props.target.prerequisites.length > 0
    );
  }

  generatedEmbedSrc() {
    return (
      "https://www.youtube.com/embed/" +
      this.props.target.youtube_video_id +
      "?rel=0"
    );
  }

  rubricButtonText() {
    if (this.props.target.has_rubric && this.props.target.status === "complete")
      return "Download Scoresheet";
    else return "Download Rubric";
  }

  render() {
    return (
      <div className="target-overlay-content-block">
        {this.hasPendingPrerequisites() && (
          <div className="target-overlay-content-block__prerequisites p-3 mb-4">
            <h6 className="font-semibold mb-3">Pending Prerequisites:</h6>
            <ol className="target-overlay-content-block__prerequisites-list mb-0">
              {this.prerequisiteLinks()}
            </ol>
          </div>
        )}
        <div className="target-overlay-content-block__container">
          <div className="target-overlay-content-block__header-container clearfix">
            <img
              className="target-overlay-content-block__header-icon pull-left"
              src={this.props.iconPaths.targetDescription}
            />
            <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
              Description
            </h5>
          </div>
          <div className="target-overlay-content-block__body target-overlay-content-block__body--description pb-3">
            <p
              dangerouslySetInnerHTML={{
                __html: this.props.target.description
              }}
            />

            {this.props.target.has_rubric && (
              <a
                className="target-overlay__link mt-1"
                target="_blank"
                href={"/targets/" + this.props.target.id + "/download_rubric"}
              >
                <span className="target-overlay__link-icon">
                  <i className="fa fa-download" />
                </span>
                <span className="target-overlay__link-text">
                  {this.rubricButtonText()}
                </span>
              </a>
            )}
          </div>
        </div>

        {this.props.target.completion_instructions && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.completionInstruction}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Completion Instruction
              </h5>
            </div>
            <div className="target-overlay-content-block__body target-overlay-content-block__body--description pb-3">
              <p>{this.props.target.completion_instructions}</p>
            </div>
          </div>
        )}

        {this.props.target.resource_url && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.resourceLinks}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Resource Link
              </h5>
            </div>
            <div className="target-overlay-content-block__body">
              <a
                className="target-overlay__link mr-2 mb-3"
                target="_blank"
                href={this.props.target.resource_url}
              >
                <span className="target-overlay__link-icon">
                  <i className="fa fa-external-link" />
                </span>
                <span className="target-overlay__link-text">Learn More</span>
              </a>
            </div>
          </div>
        )}

        {this.props.target.youtube_video_id && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.videoEmbed}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Video
              </h5>
            </div>
            <div className="target-overlay-content-block__body target-overlay-content-block__body--embed-block pb-3">
              <div>
                <iframe
                  width="640"
                  height="360"
                  src={this.generatedEmbedSrc()}
                  frameborder="0"
                  allowfullscreen
                />
              </div>
            </div>
          </div>
        )}

        {this.props.target.slideshow_embed && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.slideshowEmbed}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Presentation
              </h5>
            </div>
            <div className="target-overlay-content-block__body target-overlay-content-block__body--embed-block pb-3">
              <div
                dangerouslySetInnerHTML={{
                  __html: this.props.target.slideshow_embed
                }}
              />
            </div>
          </div>
        )}

        {this.props.target.video_embed && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.videoEmbed}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Video
              </h5>
            </div>
            <div className="target-overlay-content-block__body target-overlay-content-block__body--embed-block pb-3">
              <div
                dangerouslySetInnerHTML={{
                  __html: this.props.target.video_embed
                }}
              />
            </div>
          </div>
        )}

        {this.props.linkedResources && (
          <div className="target-overlay-content-block__container">
            <div className="target-overlay-content-block__header-container clearfix">
              <img
                className="target-overlay-content-block__header-icon pull-left"
                src={this.props.iconPaths.resourceLinks}
              />
              <h5 className="target-overlay-content-block__header m-0 pull-left font-semibold">
                Library Links
              </h5>
            </div>
            <div className="target-overlay-content-block__body">
              {this.resourceLinks()}
            </div>
          </div>
        )}
      </div>
    );
  }
}

ContentBlock.propTypes = {
  rootProps: PropTypes.object.isRequired,
  target: PropTypes.object,
  iconPaths: PropTypes.object,
  linkedResources: PropTypes.array
};
