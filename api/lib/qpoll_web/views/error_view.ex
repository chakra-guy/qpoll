defmodule QpollWeb.ErrorView do
  use QpollWeb, :view

  def render("published_poll_cant_be_modified.json", _assigns) do
    %{errors: %{detail: "Poll can't be modified when it's published"}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
