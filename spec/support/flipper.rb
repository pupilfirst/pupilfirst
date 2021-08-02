TestFlippers = ->() do
  Flipper.features.each(&:remove)
  Flipper[:clone_level].enable
end
