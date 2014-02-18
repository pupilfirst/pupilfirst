json.(user, :id, :avatar_url, :fullname)
extra_block.call(user) if defined?(extra_block) and extra_block
