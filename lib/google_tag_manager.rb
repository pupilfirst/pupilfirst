class GoogleTagManager
  def initialize(school, user, tracker: ENV['GTM_TRACKER'])
    @school = school
    @user = user
    @tracker = tracker
  end

  def with
    yield self if block_given? && tracker_defined?
  end

  def setup_data_layer
    return unless tracker_defined?
    data = {
      schoolId: school.id,
      userId: user&.id.presence || "N/A",
      userEmail: user&.email
    }
    <<~HTML
      window.dataLayer || (window.dataLayer = []);
      window.dataLayer.push(#{JSON.dump(data)});
      window.addEventListener("load", function() {
        if (window.performance && window.performance.timeOrigin && window.performance.now) {
          window.dataLayer.push({"pageLoadTime": Math.round(performance.now())});
        }
      });
    HTML
  end

  def setup_gtm_head
    return unless tracker_defined?
    <<-HTML
    (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
    new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
    j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
    'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','#{tracker}');
    HTML
  end

  def setup_gtm_body
    return unless tracker_defined?
    <<-HTML
    <!-- Google Tag Manager (noscript) -->
    <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{tracker}"
    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
    <!-- End Google Tag Manager (noscript) -->
    HTML
  end

  private
  attr_reader :school, :user, :tracker

  def tracker_defined?
    tracker.present?
  end
end
