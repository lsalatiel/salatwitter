defmodule SalatwitterWeb.PostLive.Index do
  use SalatwitterWeb, :live_view

  alias Salatwitter.Timeline
  alias Salatwitter.Timeline.Post
  
  @impl true
  def mount(_params, session, socket) do
    # Get username from session
    username = Map.get(session, "username")
    
    # Redirect to login if no username
    if is_nil(username) do
      {:ok, redirect(socket, to: ~p"/")}
    else
      # Subscribe to the posts topic
      if connected?(socket), do: Phoenix.PubSub.subscribe(Salatwitter.PubSub, "posts")
      
      {:ok, 
       socket
       |> assign(:current_username, username)
       |> stream(:posts, Timeline.list_posts())}
    end
  end
  
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post / Salatwitter")
    |> assign(:post, Timeline.get_post!(id))
  end
  
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post / Salatwitter")
    |> assign(:post, %Post{username: socket.assigns.current_username})
  end
  
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Timeline / Salatwitter")
    |> assign(:post, nil)
  end
  
  @impl true
  def handle_info({SalatwitterWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    # Broadcast the new or updated post to all clients
    Phoenix.PubSub.broadcast(Salatwitter.PubSub, "posts", {:post_updated, post})
    {:noreply, stream_insert(socket, :posts, post)}
  end
  
  # Handle pubsub broadcasts from other clients
  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end
  
  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end
  
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)
    
    # Broadcast the deletion to all clients
    Phoenix.PubSub.broadcast(Salatwitter.PubSub, "posts", {:post_deleted, post})
    
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    
    # Update the post with incremented likes_count
    updated_post = %{post | likes_count: post.likes_count + 1}
    {:ok, updated_post} = Timeline.update_post(post, %{likes_count: updated_post.likes_count})
    
    # Broadcast the update to all clients
    Phoenix.PubSub.broadcast(Salatwitter.PubSub, "posts", {:post_updated, updated_post})
    
    {:noreply, stream_insert(socket, :posts, updated_post)}
  end
  
  @impl true
  def handle_event("repost", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    
    # Update the post with incremented reposts_count
    updated_post = %{post | reposts_count: post.reposts_count + 1}
    {:ok, updated_post} = Timeline.update_post(post, %{reposts_count: updated_post.reposts_count})
    
    # Broadcast the update to all clients
    Phoenix.PubSub.broadcast(Salatwitter.PubSub, "posts", {:post_updated, updated_post})
    
    {:noreply, stream_insert(socket, :posts, updated_post)}
  end
end
