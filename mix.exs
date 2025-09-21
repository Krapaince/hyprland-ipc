defmodule HyprlandIpc.MixProject do
  use Mix.Project

  def project do
    [
      app: :hyprland_ipc,
      version: "0.2.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {HyprlandIpc, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
