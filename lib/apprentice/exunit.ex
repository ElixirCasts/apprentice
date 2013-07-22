defmodule Apprentice.ExUnit do
  def run do
    IO.puts "Your aprentice is watching your Exunit tests"
    paths = Apprentice.Workshop.exunit_paths
    ports = Apprentice.watch(paths)
    Apprentice.Server.start_link Apprentice.update_files(paths), :exunit, fn
      changed, manifest -> on_change(changed, manifest)
    end
    do_run(paths, ports)
  end

  def on_change(changed, manifest) do
    loaded = Enum.map(changed, file_to_run(&1, manifest))
    |>
    Enum.filter(fn(x) -> x end)
    |>
    Enum.map(Code.load_file(&1))
    |>
    run_files(manifest)
  end

  defp run_files([], _), do: []
  defp run_files(_, manifest) do
    case ExUnit.run do
      0 -> run_all(manifest)
      failures -> failures
    end
  end

  defp run_all(manifest) do
    Enum.each manifest, fn({file, _}) ->
      (file =~ %r/_test.exs/) && Code.load_file(file)
    end
    ExUnit.run
  end

  defp file_to_run({ file_name, _ }, manifest) do
    case file_name =~ %r/_test.exs/ do
      true -> file_name
      _ ->
        test_for_file = "test#{Regex.run(%r/[^(lib)][^\.]+/, file_name)}_test.exs"
        manifest[test_for_file] && test_for_file
    end
  end

  defp do_run(paths, ports) do
    receive do
      { port, _ } ->
        if port in ports do
          new_manifest = Apprentice.update_files(paths)
          Apprentice.Server.update_files(new_manifest, :exunit)
        end
        { :EXIT, _, reason } ->
        raise "No longer watching #{__MODULE__}. Reason: #{reason}"
    end
    do_run(paths, ports)
  end
end
