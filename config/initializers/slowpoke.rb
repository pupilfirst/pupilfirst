Slowpoke.on_timeout do |env|
  exception = env['action_dispatch.exception']

  if exception && exception.backtrace.first.include?('/active_record/')
    Slowpoke.kill
  end
end
