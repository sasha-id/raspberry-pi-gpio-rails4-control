require 'drb/drb'
require 'pi_piper'
#$SAFE = 1   # disable eval() and friends

module Rpi
  class GpioPin
    include DRb::DRbUndumped

    attr_accessor :logger, :pin

    def initialize(logger, params)
      params[:direction] = params[:direction].to_sym if params[:direction]
      @logger = logger
      @pin = PiPiper::Pin.new(params)
    end

    def on
      @logger.info  "Pin: #{@pin.pin} on"
      @pin.on
    rescue Exception => e
      @logger.error e.message
    end

    def off
      logger.info "Pin: #{@pin.pin} off"
      @pin.off
    rescue Exception => e
      @logger.error e.message
    end

    def on?
      @pin.on?
    end

    def off?
      @pin.off?
    end
      
    def click
      logger.info "Pin: #{@pin.pin} click"
      Thread.new {
        @pin.on
        sleep 1
        @pin.off
      }
    rescue Exception => e
      @logger.error e.message
    end

    def self.normalize_params(params)
      normalized = Hash[params.map{ |k, v| [k.to_sym, v] }]
      normalized[:direction] = normalized[:direction].to_sym if normalized[:direction]
      normalized[:pull] = normalized[:pull].to_sym if normalized[:pull]
      normalized[:trigger] = normalized[:trigger].to_sym if normalized[:trigger]
      normalized
    end

  end

  class Gpio
    include DRb::DRbUndumped

    attr_accessor :logger, :pins

    def initialize(logger)
      @logger = logger
      @pins = {}
    end

    def get_pin(params)
      Rpi::GpioPin.new(@logger, Rpi::GpioPin.normalize_params(params))
    end

    def watch(params)
      params = Rpi::GpioPin.normalize_params(params)
      pin = params[:pin]
      @logger.info "Watching pin/Setting initial state: ##{pin}: #{params.inspect}"

      # Set initial state
      WebsocketRails[:default].trigger :switch, {pin: pin, value: get_pin(params).on?}
      
      logger = @logger
      unless @pins[pin]
        @pins[pin] = PiPiper.watch(params) {
          logger.info "Pin #{pin} changed from #{last_value} to #{value}"
          params = {pin: pin, last_value: last_value, value: value}
          begin
            WebsocketRails[:default].trigger :switch, params
          rescue Exception => e
            logger.error e.message
          end
        }
      end
    end

    def unwatch(pin)
      return unless @pins[pin]
      @pins[pin].kill 
      @pins.delete(pin)
    end

    def unwatch_all
      @pins.each do |pin, thread|
        thread.kill
        @pins.delete(pin)
      end
    end
  end

  class Worker
    attr_accessor :logger, :host, :port

    def initialize(options={})
      [:logger, :host, :port].each do |option|
        self.send("#{option}=", options[option]) if options.has_key?(option)
      end
    end

    def start
      trap('TERM') do
        log "EXITING."
        exit
      end

      trap('INT') do
        log "EXITING."
        exit
      end

      DRb.start_service("druby://#{@host}:#{@port}", Rpi::Gpio.new(@logger))
      @logger.info "DRb server started"
      DRb.thread.join
    end


    def stop
      @exit = true
    end

    def stop?
      !!@exit
    end

  end
end
