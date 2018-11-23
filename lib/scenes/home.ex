defmodule SpawnfestClock.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @pic_path :code.priv_dir(:spawnfest_clock) |> Path.join("/static/671794.png")
  @pic_hash Scenic.Cache.Hash.file!(@pic_path, :sha)

  @graph Graph.build(font: :roboto_mono, font_size: 40, text_align: :center)
         |> text("", id: :time, translate: {350, 270})
         |> rect(
           {200, 200},
           id: :pic,
           fill: {:image, @pic_hash},
           translate: {250, 20}
         )

  def init(_, _) do
    Scenic.Cache.File.load(@pic_path, @pic_hash)

    push_graph(@graph)

    {microseconds, _} = Time.utc_now().microsecond
    Process.send_after(self(), :start_clock, 1001 - trunc(microseconds / 1000))

    state =
      %{
        graph: @graph,
        timer: nil
      }
      |> update_time()

    {:ok, state}
  end

  def handle_info(:start_clock, state) do
    # start the timer on a one-second interval
    {:ok, timer} = :timer.send_interval(1000, :second)

    state = update_time(state)

    {:noreply, %{state | timer: timer}}
  end

  def handle_info(:second, state) do
    {:noreply, update_time(state)}
  end

  {:ok, start_dt, 0} = DateTime.from_iso8601("2018-11-24T00:00:00Z")
  @start_dt start_dt

  {:ok, end_dt, 0} = DateTime.from_iso8601("2018-11-26T00:00:00Z")
  @end_dt end_dt

  defp update_time(state) do
    now = DateTime.utc_now()

    new_graph =
      case {DateTime.compare(now, @start_dt), DateTime.compare(now, @end_dt)} do
        {:lt, _} ->
          diff_str =
            DateTime.diff(now, @start_dt)
            |> Timex.Duration.from_seconds()
            |> Timex.Format.Duration.Formatters.Humanized.format()

          Graph.modify(state.graph, :time, &text(&1, "SpawnFest begins in\n\n" <> diff_str))
          |> push_graph

        {_, :lt} ->
          diff_str =
            DateTime.diff(now, @start_dt)
            |> Timex.Duration.from_seconds()
            |> Timex.Format.Duration.Formatters.Humanized.format()

          Graph.modify(
            state.graph,
            :time,
            &text(&1, "SpawnFest has began! Time left:\n\n" <> diff_str)
          )
          |> push_graph

        _ ->
          Graph.modify(state.graph, :time, &text(&1, "SpawnFest has finished!"))
      end

    %{state | graph: new_graph}
  end
end
