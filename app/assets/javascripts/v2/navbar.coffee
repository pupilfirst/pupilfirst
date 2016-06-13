$(document).on 'page:change', ->
  elSelector = '.header'
  element = document.querySelector(elSelector)
  elHeight = 0
  elTop = 0
  dHeight = 0
  wHeight = 0
  wScrollCurrent = 0
  wScrollBefore = 0
  wScrollDiff = 0
  window.addEventListener 'scroll', ->
    elHeight = element.offsetHeight
    dHeight = document.body.offsetHeight
    wHeight = window.innerHeight
    wScrollCurrent = window.pageYOffset
    wScrollDiff = wScrollBefore - wScrollCurrent
    elTop = parseInt(window.getComputedStyle(element).getPropertyValue('top')) + wScrollDiff
    if wScrollCurrent <= 0
      element.style.top = '0px'
    else if wScrollDiff > 0
      element.style.top = (if elTop > 0 then 0 else elTop) + 'px'
    else if wScrollDiff < 0
      if wScrollCurrent + wHeight >= dHeight - elHeight
        element.style.top = (if (elTop = wScrollCurrent + wHeight - dHeight) < 0 then elTop else 0) + 'px'
      else
        element.style.top = (if Math.abs(elTop) > elHeight then -elHeight else elTop) + 'px'
    wScrollBefore = wScrollCurrent
