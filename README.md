# Setting up:
 Install elixir :  ` yum install elixir`

 Install Phoenix Framework : ` mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez`


# Writing the API

the Framework creates a well structured scaffold, able to run out of the box. This makes de development a lot simpler because it provides an working exemple for the programmer to use. 
The pre-built code is also ready to use with production configurations ( with the necessary non-versionable files )
Phoenix also has resourse generators. They are :    `phoenix.gen.html`,  `phoenix.gen.json`,    `phoenix.gen.model`
 They can be easily run from the command line, and are able to generate all the structure for a basic Rest API, Web Page or Database model.  



Article : https://blog.carbonfive.com/2016/04/19/elixir-and-phoenix-the-future-of-web-apis-and-apps/

# ApiPhx

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
