defmodule Franklin.Posts.Aggregates.Post do
  defstruct [
    :published_at,
    :title,
    :id
  ]

  alias Franklin.Posts.Aggregates.Post
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Commands.DeletePost
  alias Franklin.Posts.Commands.UpdatePost
  alias Franklin.Posts.Events.PostCreated
  alias Franklin.Posts.Events.PostDeleted
  alias Franklin.Posts.Events.PostPublishedAtUpdated
  alias Franklin.Posts.Events.PostTitleUpdated

  def execute(%Post{id: nil}, %CreatePost{} = create) do
    %PostCreated{
      published_at: create.published_at,
      title: create.title,
      id: create.id
    }
  end

  def execute(%Post{id: id}, %DeletePost{id: id}) do
    %PostDeleted{id: id}
  end

  # TODO: validate
  def execute(%Post{} = post, %UpdatePost{} = update) do
    title_command =
      if post.title != update.title and not is_nil(update.title),
        do: %PostTitleUpdated{id: post.id, title: update.title}

    published_at_command =
      if post.published_at != update.published_at and not is_nil(update.published_at),
        do: %PostPublishedAtUpdated{id: post.id, published_at: update.published_at}

    [title_command, published_at_command] |> filter_commands()
  end

  def apply(%Post{} = post, %PostCreated{} = created) do
    %Post{
      post
      | published_at: created.published_at,
        title: created.title,
        id: created.id
    }
  end

  def apply(%Post{id: id}, %PostDeleted{id: id}) do
    nil
  end

  def apply(%Post{} = post, %PostTitleUpdated{title: title}) do
    %Post{post | title: title}
  end

  def apply(%Post{} = post, %PostPublishedAtUpdated{published_at: published_at}) do
    %Post{post | published_at: published_at}
  end

  # Rather than evaluate for `nil` when constructing the command list result of
  # an event, in this module we instead will removes any nil values in a final
  # filter before returning.
  defp filter_commands(command_list) do
    Enum.filter(command_list, &Function.identity/1)
  end
end
