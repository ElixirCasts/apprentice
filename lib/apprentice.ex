defmodule Apprentice do
  import Mix.Utils, only: [extract_files: 2]

  def watcher do
    Port.open { :spawn, './bin/fswatch ./ \'echo "File Changed"\'' }, [:stderr_to_stdout, :in, :exit_status, :binary, :stream, { :line, 255 }]
  end

  def run(watch_files) do
    { paths, pattern } = watch_files
    port = watcher
    #I call this the Big Ugly
    Apprentice.Server.start_link(update_files(paths, pattern), fn
      changed, manifest ->
        loaded = Enum.map changed, fn({file, _}) -> Code.load_file(file) end
        if Enum.any? loaded do
          case ExUnit.run do
            0 ->
              Enum.each manifest, fn({file, _}) -> Code.load_file(file) end
              ExUnit.run
            failures -> failures
          end
        end
    end)
    do_run(port, paths, pattern)
  end

  def update_files(paths, pattern) do
    extract_file_paths(paths, pattern) |> with_modified_times
  end

  defp do_run(port, paths, pattern) do
    receive do
      { ^port, _ } ->
        new_manifest = update_files(paths, pattern)
        Apprentice.Server.update_files(new_manifest)
    end
    do_run(port, paths, pattern)
  end

  def extract_file_paths(paths, extenstions // ["exs","ex"]) when is_list(paths) do
    extract_files(paths,extenstions)
  end

  def with_modified_times(file_paths) do
    Enum.map file_paths, fn(file_path) ->
      { file_path, File.stat!(file_path).mtime }
    end
  end
end
