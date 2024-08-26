defmodule HyprlandIpc do
  use Application

  require Logger

  def start(_start_type, _start_args) do
    children = [
      {IpcEvent, Hyprland.socket_path!(:event)}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
