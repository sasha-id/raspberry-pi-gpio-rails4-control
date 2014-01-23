require 'drb/drb'

SERVER_URI="druby://127.0.0.1:8787"
DRb.start_service

GPIO = DRbObject.new_with_uri(SERVER_URI)