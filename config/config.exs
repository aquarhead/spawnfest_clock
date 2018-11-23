use Mix.Config

config :spawnfest_clock, :viewport, %{
  name: :main_viewport,
  size: {700, 400},
  default_scene: {SpawnfestClock.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "SpawnFest Clock"]
    }
  ]
}
