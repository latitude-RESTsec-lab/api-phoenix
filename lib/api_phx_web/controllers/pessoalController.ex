defmodule ApiPhxWeb.ServidorController do
    use ApiPhxWeb, :controller
    defp conn_with_status(conn, nil) do
      conn
        |> put_status(:not_found)
    end
    defp conn_with_status(conn, code) do
        conn
          |> put_status(code)
    end
    defp conn_with_status(conn, _) do
        conn
          |> put_status(:ok)
    end
    def getServidor(conn, _params) do
        query = "select s.id_servidor, s.siape, s.id_pessoa, s.matricula_interna, s.nome_identificacao,
        p.nome, p.data_nascimento, p.sexo from rh.servidor s
    inner join comum.pessoa p on (s.id_pessoa = p.id_pessoa)"
        case Ecto.Adapters.SQL.query(ApiPhx.Repo, query) do
            {:ok, res} -> # in case the query goes ok
                servidor = Enum.map( res.rows , fn(row) -> #iteration over array to format dates acordingly to requisites
                    Enum.zip( res.columns, row |> List.update_at( 6 ,fn(tup) ->
                        :io_lib.format("~4..0B-~2..0B-~2..0B", Tuple.to_list(tup)) |> List.flatten |> to_string
                    end)) |> Map.new #Converting to type Map (basicly a JSON)
                end)
                json conn_with_status(conn, 200), servidor
            {:error , reason} -> # in case the query fails
                json conn_with_status(conn, 500), %{"Reason" => reason}
        end
    end
    def getServidorMat(conn, parameters) do
        #Regex to check if parameter is number
        case  Map.get(parameters, "matricula") |> String.match?( ~r{\b[0-9]+\b} ) do
            true ->
                query = "select s.id_servidor, s.siape, s.id_pessoa, s.matricula_interna, s.nome_identificacao,
                    p.nome, p.data_nascimento, p.sexo from rh.servidor s
                    inner join comum.pessoa p on (s.id_pessoa = p.id_pessoa) where s.siape = #{Map.get(parameters, "matricula")}"
                case Ecto.Adapters.SQL.query(ApiPhx.Repo, query) do
                    {:ok, res} ->
                        servidor = Enum.map( res.rows , fn(row) -> #iteration over array to format dates acordingly to requisites
                        Enum.zip( res.columns, row |> List.update_at( 6 ,fn(tup) ->
                            :io_lib.format("~4..0B-~2..0B-~2..0B", Tuple.to_list(tup)) |> List.flatten |> to_string
                        end)) |> Map.new
                    end)
                        json conn_with_status(conn, 200), servidor
                    {:error, error} ->
                        json conn_with_status(conn, 500), %{"Reason" => error}
                end
            false -> json conn_with_status(conn, 404), nil
        end
    end
    def postServidor(conn, parameters) do
        reasons = []
        error = False
        #REGEX checking
        if not Regex.match?(~r/^(19[0-9]{2}|2[0-9]{3})-(0[1-9]|1[012])-([123]0|[012][1-9]|31)$/, Map.get(parameters, "data_nascimento", "default")) do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[data_nascimento] missing or failed to match API requirements. It should look like this: 1969-02-12"}]}
        else
            dateJson = String.splitter(Map.get(parameters, "data_nascimento"),"-") |> Enum.take(3)
            {_,dateJson} = Date.new(elem(List.to_tuple(dateJson),0)|> String.to_integer, elem(List.to_tuple(dateJson),1)|> String.to_integer, elem(List.to_tuple(dateJson),2)|> String.to_integer)
            {dateNow, _}= :calendar.local_time()
            {_,dateNow} = Date.new(elem(dateNow,0), elem(dateNow,1), elem(dateNow,2))
            if Date.compare(dateJson,dateNow) == :gt do
                {error, reasons} = {True, reasons ++ [%{"Reason" => "[data_nascimento] missing or failed to match API requirements. It should not be in future"}]}
            end
        end
        if not Regex.match?(~r/^([A-Z][a-z]+([ ]?[a-z]?['-]?[A-Z][a-z]+)*)$/, Map.get(parameters, "nome", "default")) do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[name] missing or failed to match API requirements. It should look like this: Firstname Middlename(optional) Lastname"}]}
        end
        if String.length(Map.get(parameters, "nome", "default")) > 100 do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[name] missing or failed to match API requirements. It shoud have a maximum of 100 characters"}]}
        end
        if not Regex.match?(~r/^([A-Z][a-z]+([ ]?[a-z]?['-]?[A-Z][a-z]+)*)$/, Map.get(parameters, "nome_identificacao", "default")) do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[nome_identificacao] missing or failed to match API requirements. It should look like this: Firstname Middlename(optional) Lastname"}]}
        end
        if String.length(Map.get(parameters, "nome_identificacao", "default")) > 100 do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[nome_identificacao] missing or failed to match API requirements. It shoud have a maximum of 100 characters"}]}
        end
        if not Regex.match?(~r/\b[MF]{1}\b/, Map.get(parameters, "sexo", "default")) do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[sexo] missing or failed to match API requirements. It should look like this: M for male, F for female"}]}
        end
        if not is_number Map.get(parameters, "id_pessoa") do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[id_pessoa] missing or failed to match API requirements. It should be numeric. "}]}
        end
        if not is_number Map.get(parameters, "siape") do
            {error, reasons} = {True, reasons ++ [%{"Reason" => "[siape] missing or failed to match API requirements. It should be numeric. "}]}
        end
        if error == True do
            IO.warn "Error in data checking"
            json conn_with_status(conn, 400), reasons
        #END OF REGEX
        else
            mat = :crypto.hash(:md5,  Map.get(parameters, "nome") <> DateTime.to_string DateTime.utc_now )
            |> :binary.bin_to_list |> Enum.join |> String.to_integer |> rem(999999999)
            IO.inspect query = "INSERT INTO rh.servidor_tmp(
                nome, nome_identificacao, siape, id_pessoa, matricula_interna, id_foto,
                data_nascimento, sexo)
                VALUES ('#{Map.get(parameters, "nome")}', '#{Map.get(parameters, "nome_identificacao")}', #{Map.get(parameters, "siape")}, #{Map.get(parameters, "id_pessoa")}, #{mat}, null,
                '#{Map.get(parameters, "data_nascimento")}', '#{Map.get(parameters, "sexo")}');"
                case Ecto.Adapters.SQL.query(ApiPhx.Repo, query) do
                    {:ok, res} ->
                        conn = %{conn | resp_headers: [{"location", (ApiPhxWeb.Router.Helpers.url(conn) <> "/api/servidor/" <> Integer.to_string(mat))}]}
                        text conn_with_status(conn, 201), nil
                    {:error, error} ->
                        json conn_with_status(conn, 500), %{"Reason" => error}
                end
        end
    end
    def calculate(conn, parameters) do
        reasons = []
        error = False
        #REGEX checking
        IO.puts(Map.get(parameters))
        #END OF REGEX

        # if
        #     {:ok, res} ->
        #         conn = %{conn | resp_headers: [{"location", (ApiPhxWeb.Router.Helpers.url(conn) <> "/api/servidor/" <> Integer.to_string(mat))}]}
        #         text conn_with_status(conn, 201), nil
        #     {:error, error} ->
        #         json conn_with_status(conn, 500), %{"Reason" => error}
        # end
    end
  end
