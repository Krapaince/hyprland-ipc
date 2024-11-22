defmodule Hyprland do
  def socket_path!(:event), do: do_socket_path!(".socket2.sock")

  defp do_socket_path!(socket_filename) do
    hyprland_instance = System.fetch_env!("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime_dir = System.fetch_env!("XDG_RUNTIME_DIR")

    Path.join([xdg_runtime_dir, "hypr", hyprland_instance, socket_filename])
  end

  def handle_event("openwindow", [window_address, _, _, "Firefox - Sharing Indicator" <> _]) do
    Hyprctl.Dispatch.close_window("address:0x#{window_address}")
  end

  def handle_event("windowtitle", [window_address]) do
    client = Hyprctl.clients() |> Enum.find(&String.ends_with?(&1["address"], window_address))

    case client do
      %{"initialClass" => "firefox", "title" => "FW" <> title_remainder} ->
        move_firefox_window(window_address, title_remainder)

      %{"title" => "Extension: (Bitwarden Password Manager) - Bitwarden — Mozilla Firefox"} ->
        handle_bitwarden_extension(client)

      _ ->
        nil
    end
  end

  def handle_event(_event, _data), do: nil

  defp move_firefox_window(window_addr, title_remainder) do
    # Used with https://addons.mozilla.org/en-US/firefox/addon/window-titler/
    case Integer.parse(title_remainder) do
      {workspace, _} ->
        Hyprctl.Dispatch.move_to_workspace_silent(
          "address:0x" <> window_addr,
          to_string(workspace)
        )

      :error ->
        nil
    end
  end

  defp handle_bitwarden_extension(client) do
    window = "address:" <> client["address"]

    if match?(%{"fullscreen" => internal, "focusHistoryID" => 0} when internal != 0, client),
      do: Hyprctl.Dispatch.fullscreen(window)

    resize_window(client, 450)
  end

  defp resize_window(client, desired_x) do
    window = "address:" <> client["address"]
    %{"size" => [x, _]} = client

    Hyprctl.Dispatch.resize_window_pixel(window, -1, 0)
    %{"size" => [new_x, _]} = Hyprctl.client(client["address"])

    x =
      if new_x > x do
        new_x - desired_x
      else
        desired_x - new_x
      end

    Hyprctl.Dispatch.resize_window_pixel(window, x, 0)
  end
end
