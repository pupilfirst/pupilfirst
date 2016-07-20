setupPolicies = ->
  $('#show-privacy-policy').click ->
    policyModal = $('#policy-modal')

    if policyModal.data('loaded') == 'privacy'
      policyModal.modal('show')
    else
      # Load privacy policy.
      $.get 'policies/privacy', (data) ->
        policyModal.find('.modal-title').html('Privacy Policy')
        policyModal.find('.modal-body').html(data)
        policyModal.modal('show')
        policyModal.data('loaded', 'privacy')

  $('#show-terms-of-use').click ->
    policyModal = $('#policy-modal')

    if policyModal.data('loaded') == 'terms'
      policyModal.modal('show')
    else
      # Load terms of use.
      $.get 'policies/terms', (data) ->
        policyModal.find('.modal-title').html('Terms of Use')
        policyModal.find('.modal-body').html(data)
        policyModal.modal('show')
        policyModal.data('loaded', 'terms')

$(document).on 'page:change', setupPolicies
