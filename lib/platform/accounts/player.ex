defmodule Platform.Accounts.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :display_name, :string
    field :password, :string, virtual: true
    field :password_digest, :string
    field :score, :integer, default: 0
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:display_name, :password, :username, :score])
    |> validate_required([:username])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 2, max: 100)
    |> validate_length(:password, min: 2, max: 100)
    |> put_pass_digest()
  end

  @doc false
  def registration_changeset(player, attrs) do
    player
    |> cast(attrs, [:password, :username])
    |> validate_required([:password, :username])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 2, max: 100)
    |> validate_length(:password, min: 2, max: 100)
    |> put_pass_digest()
  end

  defp put_pass_digest(player),
    do: put_pass_digest2(player)

  defp put_pass_digest2(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = player),
    do: put_change(player, :password_digest, Comeonin.Bcrypt.hashpwsalt(pass))

  defp put_pass_digest2(player),
    do: player
end
