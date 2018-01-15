defmodule ApiPhxWeb.PessoalController do
    use ApiPhxWeb, :controller

    defp conn_with_status(conn, nil) do
      conn
        |> put_status(:not_found)
    end
    defp conn_with_status(conn, _) do
      conn
        |> put_status(:ok)
    end
  
  
    def getPessoal(conn, _params) do
        query = "select s.id_servidor, s.siape, s.id_pessoa, s.matricula_interna, s.nome_identificacao,
        p.nome, p.data_nascimento, p.sexo from rh.servidor s
    inner join comum.pessoa p on (s.id_pessoa = p.id_pessoa)"
    # IO.inspect Ecto.Adapters.SQL.query(ApiPhx.Repo, query, [])
        case Ecto.Adapters.SQL.query(ApiPhx.Repo, query) do
            {:ok, res} -> 
                pessoal = Enum.map( res.rows , fn(row) ->
                    Enum.zip( res.columns, row |> List.update_at( 6 ,fn(tup) ->
                        :io_lib.format("~4..0B-~2..0B-~2..0B", Tuple.to_list(tup)) |> List.flatten |> to_string
                    end)) |> Map.new
                end) 
                json conn_with_status(conn, pessoal), pessoal
            {status, _} -> IO.inspect(status)
        end
      
      
    end

    def getPessoalMat(conn, parameters) do
        Map.get(parameters, "matricula")  |> IO.inspect
        case  Map.get(parameters, "matricula") |> String.match?( ~r{\b[0-9]+\b} ) do
            true ->
                query = "select s.id_servidor, s.siape, s.id_pessoa, s.matricula_interna, s.nome_identificacao,
                    p.nome, p.data_nascimento, p.sexo from rh.servidor s
                    inner join comum.pessoa p on (s.id_pessoa = p.id_pessoa) where s.matricula_interna = #{Map.get(parameters, "matricula")}"         
                case Ecto.Adapters.SQL.query(ApiPhx.Repo, query) do
                    {:ok, res} -> 
                        pessoal = Enum.map( res.rows , fn(row) ->
                        Enum.zip( res.columns, row |> List.update_at( 6 ,fn(tup) ->
                            :io_lib.format("~4..0B-~2..0B-~2..0B", Tuple.to_list(tup)) |> List.flatten |> to_string
                        end)) |> Map.new
                    end) 
                    json conn_with_status(conn, pessoal), pessoal
                    {status, _} -> IO.inspect(status)
                end
            false -> json conn_with_status(conn, nil), nil
        end
    end
  end