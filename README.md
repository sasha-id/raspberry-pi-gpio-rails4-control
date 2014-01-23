Ruby on Rails Raspberry Pi GPIO Control
================================

Raspberry Pi Control based on Ruby on Rails 4 and websockets

## How To

* Start DRb server as `root` user:

```
sudo bundle exec ruby bin/gpio start
```
* Start Rails server in develpment mode:

```
thin start
```

or

in production mode, first compile assets then start thin:

```
RAILS_ENV=production bundle exec rake assets:precompile
thin -e production start
```

## Demo

[![Video Demonstration](https://raw.github.com/alex-klepa/raspberry-pi-gpio-rails4-control/master/screenshot.png)](http://www.youtube.com/watch?v=34MCR2j06ig)

