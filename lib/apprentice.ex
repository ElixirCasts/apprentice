defmodule Apprentice do
  import Mix.Utils, only: [extract_files: 2]

  def watch(paths) do
    paths |> Enum.map fn(path) ->
      Port.open { :spawn, '#{__DIR__}/../bin/fswatch ./#{path} \'echo "File Changed"\'' },
      [:stderr_to_stdout, :in, :exit_status, :binary, :stream, { :line, 255 }]
    end
  end

  def run(apprentices // [Apprentice.ExUnit]) do
    Enum.each apprentices, fn(apprentice) ->
      spawn_link apprentice, :run, []
    end
    do_run
  end

  def do_run do
    receive do
      resp -> IO.puts inspect resp
    end
    do_run
  end

  def update_files(paths) do
    extract_file_paths(paths) |> with_modified_times
  end

  def update_files(paths, extentions) do
    extract_file_paths(paths, extentions) |> with_modified_times
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
