$(document).on 'page:change', ->
  $(".company-carousel").owlCarousel
    items:4
    margin:10
    autoPlay:45000
    stopOnHover:true

  $(".testimonial-carousel").owlCarousel
    items:1
    itemsDesktop:[1920,1]
    itemsTablet:[768,1]

animateHeroHeadline = ->
  #set animation timing
  animationDelay = 2500
  barAnimationDelay = 3800
  barWaiting = barAnimationDelay - 3000
  lettersDelay = 50
  typeLettersDelay = 50
  selectionDuration = 500
  typeAnimationDelay = selectionDuration + 800
  revealDuration = 600
  revealAnimationDelay = 1500

  initHeadline = ->
#insert <i> element for each letter of a changing word
    singleLetters $('.hero-headline.letters').find('b')
    #initialise headline animation
    animateHeadline $('.hero-headline')
    return

  singleLetters = ($words) ->
    $words.each ->
      word = $(this)
      letters = word.text().split('')
      selected = word.hasClass('is-visible')
      for i of letters
        `i = i`
        if word.parents('.rotate-2').length > 0
          letters[i] = '<em>' + letters[i] + '</em>'
        letters[i] = if selected then '<i class="in">' + letters[i] + '</i>' else '<i>' + letters[i] + '</i>'
      newLetters = letters.join('')
      word.html(newLetters).css 'opacity', 1
      return
    return

  animateHeadline = ($headlines) ->
    duration = animationDelay
    $headlines.each ->
      headline = $(this)
      if headline.hasClass('loading-bar')
        duration = barAnimationDelay
        setTimeout (->
          headline.find('.hero-words-wrapper').addClass 'is-loading'
          return
        ), barWaiting
      else if headline.hasClass('clip')
        spanWrapper = headline.find('.hero-words-wrapper')
        newWidth = spanWrapper.width() + 10
        spanWrapper.css 'width', newWidth
      else if !headline.hasClass('type')
#assign to .hero-words-wrapper the width of its longest word
        words = headline.find('.hero-words-wrapper b')
        width = 0
        words.each ->
          wordWidth = $(this).width()
          if wordWidth > width
            width = wordWidth
          return
        headline.find('.hero-words-wrapper').css 'width', width
      #trigger animation
      setTimeout (->
        hideWord headline.find('.is-visible').eq(0)
        return
      ), duration
      return
    return

  hideWord = ($word) ->
    nextWord = takeNext($word)
    if $word.parents('.hero-headline').hasClass('type')
      parentSpan = $word.parent('.hero-words-wrapper')
      parentSpan.addClass('selected').removeClass 'waiting'
      setTimeout (->
        parentSpan.removeClass 'selected'
        $word.removeClass('is-visible').addClass('is-hidden').children('i').removeClass('in').addClass 'out'
        return
      ), selectionDuration
      setTimeout (->
        showWord nextWord, typeLettersDelay
        return
      ), typeAnimationDelay
    else if $word.parents('.hero-headline').hasClass('letters')
      bool = if $word.children('i').length >= nextWord.children('i').length then true else false
      hideLetter $word.find('i').eq(0), $word, bool, lettersDelay
      showLetter nextWord.find('i').eq(0), nextWord, bool, lettersDelay
    else if $word.parents('.hero-headline').hasClass('clip')
      $word.parents('.hero-words-wrapper').animate { width: '2px' }, revealDuration, ->
        switchWord $word, nextWord
        showWord nextWord
        return
    else if $word.parents('.hero-headline').hasClass('loading-bar')
      $word.parents('.hero-words-wrapper').removeClass 'is-loading'
      switchWord $word, nextWord
      setTimeout (->
        hideWord nextWord
        return
      ), barAnimationDelay
      setTimeout (->
        $word.parents('.hero-words-wrapper').addClass 'is-loading'
        return
      ), barWaiting
    else
      switchWord $word, nextWord
      setTimeout (->
        hideWord nextWord
        return
      ), animationDelay
    return

  showWord = ($word, $duration) ->
    if $word.parents('.hero-headline').hasClass('type')
      showLetter $word.find('i').eq(0), $word, false, $duration
      $word.addClass('is-visible').removeClass 'is-hidden'
    else if $word.parents('.hero-headline').hasClass('clip')
      $word.parents('.hero-words-wrapper').animate { 'width': $word.width() + 10 }, revealDuration, ->
        setTimeout (->
          hideWord $word
          return
        ), revealAnimationDelay
        return
    return

  hideLetter = ($letter, $word, $bool, $duration) ->
    $letter.removeClass('in').addClass 'out'
    if !$letter.is(':last-child')
      setTimeout (->
        hideLetter $letter.next(), $word, $bool, $duration
        return
      ), $duration
    else if $bool
      setTimeout (->
        hideWord takeNext($word)
        return
      ), animationDelay
    if $letter.is(':last-child') and $('html').hasClass('no-csstransitions')
      nextWord = takeNext($word)
      switchWord $word, nextWord
    return

  showLetter = ($letter, $word, $bool, $duration) ->
    $letter.addClass('in').removeClass 'out'
    if !$letter.is(':last-child')
      setTimeout (->
        showLetter $letter.next(), $word, $bool, $duration
        return
      ), $duration
    else
      if $word.parents('.hero-headline').hasClass('type')
        setTimeout (->
          $word.parents('.hero-words-wrapper').addClass 'waiting'
          return
        ), 200
      if !$bool
        setTimeout (->
          hideWord $word
          return
        ), animationDelay
    return

  takeNext = ($word) ->
    if !$word.is(':last-child') then $word.next() else $word.parent().children().eq(0)

  takePrev = ($word) ->
    if !$word.is(':first-child') then $word.prev() else $word.parent().children().last()

  switchWord = ($oldWord, $newWord) ->
    $oldWord.removeClass('is-visible').addClass 'is-hidden'
    $newWord.removeClass('is-hidden').addClass 'is-visible'
    return

  initHeadline()

showTalentFormOnError = ->
  talentFormModal = $('.invest-hire-modal')

  if talentFormModal.data('showOnLoad')
    talentFormModal.modal('show')

clearAllFormInterests = ->
  interestChoices = ['joining_svco_as_faculty', 'accelerating_startups', 'investing_in_startups', 'hiring_founders', 'acquihiring_teams']

  $.each interestChoices, (index, selection) ->
    $("#talent_form_query_type_#{selection}").prop('checked', false)

handleActionButtonClicks = ->
  $('.talent-action-btn').click (event) ->
    selection = $(event.target).data('selection')
    clearAllFormInterests()
    $("#talent_form_query_type_#{selection}").prop('checked', true)
    $('.invest-hire-modal').modal('show')

$(document).on 'page:change', animateHeroHeadline
$(document).on 'page:change', showTalentFormOnError
$(document).on 'page:change', handleActionButtonClicks
