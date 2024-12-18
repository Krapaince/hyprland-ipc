defmodule IpcEvent do
  use GenServer

  import Events, only: [events: 0]

  require Logger

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(hyprland_socket2_path) do
    Logger.metadata(module: __MODULE__)

    case :gen_tcp.connect({:local, hyprland_socket2_path}, 0,
           reuseaddr: true,
           packet: :line,
           buffer: 1024
         ) do
      {:ok, socket} ->
        Logger.info("Start")
        {:ok, %{socket: socket}}

      {:error, reason} ->
        Logger.info("Stop, #{reason}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_info({:tcp, _port, event}, state) do
    [event, event_data] =
      event
      |> to_string()
      |> String.trim_trailing()
      |> String.split(">>", parts: 2)

    case Map.fetch(events(), event) do
      {:ok, %{arg_count: arg_count}} ->
        event_args = String.split(event_data, ",", parts: arg_count)

        Hyprland.handle_event(event, event_args)

      :error ->
        nil
    end

    {:noreply, state}
  end
end
