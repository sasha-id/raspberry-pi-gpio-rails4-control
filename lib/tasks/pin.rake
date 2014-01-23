namespace :pin do

  desc "Set pin on"
  task :on, [:pin] => [:environment] do |t, args|
    puts "Pin:  ##{args[:pin]} on"
    message = {pin: args[:pin], last_value: 0, value: 1}
    begin
      WebsocketRails[:default].trigger :switch, message
    rescue Exception => e
      puts e.message
    end
  end

  desc "Set pin off"
  task :off, [:pin] => [:environment] do |t, args|
    puts "Pin:  ##{args[:pin]} off"
    params = {pin: args[:pin], last_value: 0, value: 0}
    begin
      WebsocketRails[:default].trigger :switch, params
    rescue Exception => e
      puts e.message
    end
  end
end