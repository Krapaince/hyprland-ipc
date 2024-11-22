defmodule Events do
  # Extract from Hyrland wiki v0.45
  @events %{
            "openwindow" => [:window_address, :workspace_name, :window_class, :window_title],
            "windowtitle" => [:window_address]
          }
          |> Map.new(fn {key, args} -> {key, %{arg_names: args, arg_count: length(args)}} end)

  def events(), do: @events
end
