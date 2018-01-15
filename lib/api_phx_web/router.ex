defmodule ApiPhxWeb.Router do
  use ApiPhxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiPhxWeb do
    pipe_through :api

    get "/servidores", PessoalController, :getPessoal
    get "/servidor/:matricula", PessoalController, :getPessoalMat 
  end
end
