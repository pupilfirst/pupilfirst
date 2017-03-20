class FounderDashboardResourcesBar extends React.Component {
  showSlides(event) {
    let slidesModal = $('.view-slides');
    let viewSlidesButton = $(event.target).closest('button');

    slidesModal.on('show.bs.modal', function () {
      $('#slides-wrapper').html(viewSlidesButton.data('embed-code'));
    });

    slidesModal.on('hide.bs.modal', function() {
      $('#slides-wrapper').html('');
    });

    slidesModal.modal();
  }

  render() {
    return(
      <div className="m-t-1">
        { this.props.target.slideshow_embed &&
        <button className="btn btn-with-icon btn-sm btn-ghost-secondary text-uppercase m-r-1 m-b-1 view-slides-btn" data-toggle="modal" data-embed-code={ this.props.target.slideshow_embed } onClick={ this.showSlides }>
          <i className="fa fa-slideshare"/>
          <span>&nbsp;View Slides</span>
        </button>
        }

        { this.props.target.resource_url &&
        <a className="btn btn-with-icon btn-sm btn-ghost-secondary text-uppercase m-r-1 m-b-1" target='_blank' href={ this.props.target.resource_url }>
          <i className="fa fa-book"/>
          <span>&nbsp;Learn More</span>
        </a>
        }

        { this.props.target.has_rubric &&
        <a className="btn btn-with-icon btn-sm btn-ghost-secondary text-uppercase m-b-1" target='_blank' href={'/targets/' + this.props.target.id + '/download_rubric'}>
          <i className="fa fa-download"/>
          <span>&nbsp;Download Rubric</span>
        </a>
        }
      </div>
    );
  }
}

FounderDashboardTargetDescription.propTypes = {
  target: React.PropTypes.object
};
