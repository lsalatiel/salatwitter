defmodule Salatwitter.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :username, :string, default: "srjheam"
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:username, :body, :likes_count, :reposts_count])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 250)
  end
end
