# lib/salatwitter_web/live/auth_live/index.ex
defmodule SalatwitterWeb.AuthLive.Index do
  use SalatwitterWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    # Check for username in the session
    username = Map.get(session, "username")
    
    # If user already has a username, redirect to posts
    if username do
      {:ok, push_navigate(socket, to: ~p"/posts")}
    else
      {:ok, assign(socket, username: "", error: nil)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow-md">
      <h1 class="text-2xl font-bold mb-6 text-center">Welcome to Salatwitter!</h1>
      
      <.simple_form for={%{}} phx-submit="save_username">
        <.input name="username" value={@username} placeholder="Choose your username" required />
        
        <%= if @error do %>
          <p class="mt-1 text-sm text-red-600"><%= @error %></p>
        <% end %>
        
        <:actions>
          <.button class="w-full" phx-disable-with="Saving...">Get Started</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("save_username", %{"username" => username}, socket) do
    # Validate username
    if String.length(username) >= 3 do
      # We need to redirect to a controller that will set the session
      {:noreply, 
       socket
       |> redirect(to: ~p"/auth/login?username=#{username}")}
    else
      {:noreply, assign(socket, error: "Username must be at least 3 characters", username: username)}
    end
  end
end
