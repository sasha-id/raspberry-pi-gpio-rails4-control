# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
RpiWebsockets::Application.config.secret_key_base = '2ee65e00c0fb3afdb7d09bb592ddfb5c7a9b3c7d9323e4357825f9a459011b1c69a779572124553aa67cc14fea6266998cb1ea045929c3d418e841fd1e6d6d74'
