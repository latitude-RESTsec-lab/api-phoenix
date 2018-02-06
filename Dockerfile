FROM elixir:latest

# Install hex (Elixir package manager)
RUN HTTPS_PROXY=https://10.30.0.10:3128 mix local.hex --force

RUN HTTPS_PROXY=https://10.30.0.10:3128 mix local.rebar --force

RUN HTTPS_PROXY=https://10.30.0.10:3128 mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez
# Copy all dependencies files
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
#RUN apt-get install -y -q nodejs

WORKDIR /app

ADD . /app

# Install all production dependencies
RUN HTTPS_PROXY=https://10.30.0.10:3128 mix deps.get --only prod

RUN HTTPS_PROXY=https://10.30.0.10:3128 mix deps.update --force --all
# Compile all dependencies
RUN mix deps.compile

# # Compile the entire project
# RUN mix compile
EXPOSE 443

# # Run Ecto migrations and Phoenix server as an initial command
CMD mix phx.server
