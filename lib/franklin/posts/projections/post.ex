defmodule Franklin.Posts.Projections.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @derive {Phoenix.Param, key: :uuid}

  schema "posts" do
    field :title, :string
    field :published_at, :utc_datetime

    timestamps()
  end

  def update_changeset(post, attrs \\ %{}) do
    post
    |> cast(attrs, [:title, :published_at])
  end
end
