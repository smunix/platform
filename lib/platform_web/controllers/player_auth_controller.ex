defmodule PlatformWeb.PlayerAuthController do
  use PlatformWeb, :controller

  import Plug.Conn

  alias Platform.Accounts.Player

  def init(opts),
    do: Keyword.fetch!(opts, :repo)

  def call(conn, repo) do
    player_id = get_session(conn, :player_id)
    player = player_id && repo.get(Player, player_id)
    assign(conn, :current_user, player)
  end

  def sign_in(conn, player) do
    conn
    |> assign(:current_user, player)
    |> put_session(:player_id, player.id)
    |> configure_session(renew: true)
  end

  def create(conn, %{"player" => player_params}) do
    case Platform.Accounts.create_player(player_params) do
      {:ok, player} ->
        conn
        |> PlatformWeb.PlayerAuthController.sign_in(player)
        |> put_flash(:info, "Player created successfully")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def sign_in_with_username_and_password(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    player = repo.get_by(Player, username: username)

    cond do
      player && Comeonin.Bcrypt.checkpw(given_pass, player.password_digest) ->
        {:ok, sign_in(conn, player)}

      player ->
        {:error, :unauthorized, conn}

      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def sign_out(conn) do
    configure_session(conn, drop: true)
  end
end
