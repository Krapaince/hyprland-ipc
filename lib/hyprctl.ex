defmodule Hyprctl.Dispatch do
  def close_window(window), do: Hyprctl.dispatch("closewindow", window)
  def fullscreen(window), do: Hyprctl.dispatch("fullscreen", window)

  def move_to_workspace_silent(window, workspace),
    do: Hyprctl.dispatch("movetoworkspacesilent", "#{workspace},#{window}")

  def resize_window_pixel(window, x, y),
    do: Hyprctl.dispatch("resizewindowpixel", "#{x} #{y},#{window}")
end

defmodule Hyprctl do
  require Logger

  def dispatch(dispatcher), do: do_dispatch([dispatcher], quiet: true)
  def dispatch(dispatcher, arg), do: do_dispatch([dispatcher, arg], quiet: true)

  defp do_dispatch(args, opts) do
    args = Enum.join(args, " ") |> List.wrap()
    Logger.notice(["Dispatcing ~> ", inspect(args, pretty: true)])

    run!("dispatch", args, opts)
  end

  def client(address), do: Enum.find(clients(), &String.ends_with?(&1["address"], address))
  def clients(), do: run!("clients", [], json: true)

  @type option :: {:json, boolean()} | {:quiet, boolean()}
  @spec run!(String.t(), [String.t()], [option]) :: :ok | term()
  def run!(cmd, args, opts \\ []) do
    quiet = Keyword.get(opts, :quiet, false)

    flags =
      Enum.flat_map(opts, fn
        {:json, true} -> [?j]
        {:quiet, true} -> [?q]
        _ -> []
      end)
      |> then(fn
        [] -> []
        args -> [?- | args]
      end)
      |> List.to_string()

    Logger.debug("hyprctl #{flags} #{cmd} \"#{Enum.join(args, " ")}\"")

    {stdout, 0} = System.cmd("hyprctl", [flags, cmd | args])

    if quiet, do: :ok, else: Jason.decode!(stdout)
  end
end
