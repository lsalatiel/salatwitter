defmodule SalatwitterWeb.AuthController do
  use SalatwitterWeb, :controller

  def login(conn, %{"username" => username}) do
    # Store username in session
    conn
    |> put_session(:username, username)
    |> redirect(to: ~p"/posts")
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end
end
