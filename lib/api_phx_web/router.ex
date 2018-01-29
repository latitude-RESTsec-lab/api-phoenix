defmodule ApiPhxWeb.Router do
  use ApiPhxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiPhxWeb do
    pipe_through :api

    get "/servidores", ServidorController, :getServidor
    get "/servidor/:matricula", ServidorController, :getServidorMat 
    post "/servidor/", ServidorController, :postServidor 
  end
end
