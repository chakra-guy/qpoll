defmodule QpollWeb.PollChannel do
  use QpollWeb, :channel

  def join("poll:" <> _poll_id, _payload, socket) do
    {:ok, socket}
  end
end
