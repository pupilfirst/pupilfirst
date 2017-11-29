class FounderDashboardResourcesBar extends React.Component {
  showEmbed(event) {
    let embedModal = $('.view-embed');
    let viewEmbedButton = $(event.target).closest('button');

    embedModal.on('show.bs.modal', function () {
      $('#embed-wrapper').html(viewEmbedButton.data('embed-code'));
    });

    embedModal.on('hide.bs.modal', function() {
      $('#embed-wrapper').html('');
    });

    embedModal.modal();
  }

  render() {
    return(
      <div className="m-t-1">
        { this.props.target.slideshow_embed &&
        <button className="btn btn-with-icon btn-sm btn-ghost-secondary text-uppercase m-r-1 m-b-1" data-toggle="modal" data-embed-code={ this.props.target.slideshow_embed } onClick={ this.showEmbed }>
          <i className="fa fa-slideshare"/>
          <span>&nbsp;View Slides</span>
        </button>
        }

        { this.props.target.video_embed &&
        <button className="btn btn-with-icon btn-sm btn-ghost-secondary text-uppercase m-r-1 m-b-1" data-toggle="modal" data-embed-code={ this.props.target.video_embed } onClick={ this.showEmbed }>
          <i className="fa fa-play"/>
          <span>&nbsp;Play Video</span>
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

FounderDashboardResourcesBar.propTypes = {
  target: PropTypes.object
};
