$(document).on 'page:change', ->
  articlesWrapper = $('.cd-articles')

  checkRead = ->
    if !scrolling
      scrolling = true
      if !window.requestAnimationFrame then setTimeout(updateArticle, 300) else window.requestAnimationFrame(updateArticle)
    return

  checkSidebar = ->
    if !sidebarAnimation
      sidebarAnimation = true
      if !window.requestAnimationFrame then setTimeout(updateSidebarPosition, 300) else window.requestAnimationFrame(updateSidebarPosition)
    return

  resetScroll = ->
    if !resizing
      resizing = true
      if !window.requestAnimationFrame then setTimeout(updateParams, 300) else window.requestAnimationFrame(updateParams)
    return

  updateParams = ->
    windowHeight = $(window).height()
    mq = checkMQ()
    $(window).off 'scroll', checkRead
    $(window).off 'scroll', checkSidebar
    if mq == 'desktop'
      $(window).on 'scroll', checkRead
      $(window).on 'scroll', checkSidebar
    resizing = false
    return

  updateArticle = ->
    scrollTop = $(window).scrollTop()
    articles.each ->
      article = $(this)
      articleTop = article.offset().top
      articleHeight = article.outerHeight()
      articleSidebarLink = articleSidebarLinks.eq(article.index()).children('a')
      if article.is(':last-of-type')
        articleHeight = articleHeight - windowHeight
      if articleTop > scrollTop
        articleSidebarLink.removeClass 'read reading'
      else if scrollTop >= articleTop and articleTop + articleHeight > scrollTop
        dashoffsetValue = svgCircleLength * (1 - ((scrollTop - articleTop) / articleHeight))
        articleSidebarLink.addClass('reading').removeClass('read').find('circle').attr 'stroke-dashoffset': dashoffsetValue
        changeUrl articleSidebarLink.attr('href')
      else
        articleSidebarLink.removeClass('reading').addClass 'read'
      return
    scrolling = false
    return

  updateSidebarPosition = ->
    articlesWrapperTop = articlesWrapper.offset().top
    articlesWrapperHeight = articlesWrapper.outerHeight()
    scrollTop = $(window).scrollTop()
    if scrollTop < articlesWrapperTop
      aside.removeClass('fixed').attr 'style', ''
    else if scrollTop >= articlesWrapperTop and scrollTop < articlesWrapperTop + articlesWrapperHeight - windowHeight
      aside.addClass('fixed').attr 'style', ''
    else
      articlePaddingTop = Number(articles.eq(1).css('padding-top').replace('px', ''))
      if aside.hasClass('fixed')
        aside.removeClass('fixed').css 'top', articlesWrapperHeight + articlePaddingTop - windowHeight + 'px'
    sidebarAnimation = false
    return

  changeUrl = (link) ->
    pageArray = location.pathname.split('/')
    actualPage = pageArray[pageArray.length - 1]
    if actualPage != link and history.pushState
      window.history.pushState { path: link }, '', link
    return

  checkMQ = ->
    window.getComputedStyle(articlesWrapper.get(0), '::before').getPropertyValue('content').replace(/'/g, '').replace /"/g, ''

  if articlesWrapper.length > 0
    # cache jQuery objects
    windowHeight = $(window).height()
    articles = articlesWrapper.find('article')
    aside = $('.cd-read-more')
    articleSidebarLinks = aside.find('li')
    # initialize variables
    scrolling = false
    sidebarAnimation = false
    resizing = false
    mq = checkMQ()
    svgCircleLength = parseInt(Math.PI * articleSidebarLinks.eq(0).find('circle').attr('r') * 2)
    # check media query and bind corresponding events
    if mq == 'desktop'
      $(window).on 'scroll', checkRead
      $(window).on 'scroll', checkSidebar
    $(window).on 'resize', resetScroll
    updateArticle()
    updateSidebarPosition()
    aside.on 'click', 'a', (event) ->
      event.preventDefault()
      selectedArticle = articles.eq($(this).parent('li').index())
      selectedArticleTop = selectedArticle.offset().top
      $(window).off 'scroll', checkRead
      $('body,html').animate { 'scrollTop': selectedArticleTop + 2 }, 300, ->
        checkRead()
        $(window).on 'scroll', checkRead
        return
      return
