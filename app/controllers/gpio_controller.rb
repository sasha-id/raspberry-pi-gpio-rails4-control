class GpioController < WebsocketRails::BaseController
  def initialize_session
    controller_store[:message_count] = 0
  end

  def client_connected
    Rails.logger.info "Client connected"
    #WebsocketRails[:default].subscribe connection   # Server-side subscription
  end

  def watch
    Rails.logger.info data.inspect
    data.each do |pin|
      GPIO.watch(pin)
    end
  end

  def switch
    Rails.logger.info "GpioController.switch:" + data.inspect
    pin = GPIO.get_pin(pin: data['pin'], direction: data['direction'])
    case data['value']
    when 'click'
      pin.click
    when true
      pin.on
    when false
      pin.off
    end
  end
end