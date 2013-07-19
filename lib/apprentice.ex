defmodule Apprentice do
  import Mix.Utils, only: [extract_files: 2]

  def watch(paths) do
    paths |> Enum.each fn(path) ->
      Port.open { :spawn, './deps/apprentice/bin/fswatch ./#{path} \'echo "File Changed"\'' },
      [:stderr_to_stdout, :in, :exit_status, :binary, :stream, { :line, 255 }]
    end
  end

  def run(watch_files) do
    { paths, _ } = watch_files
    watch(paths)
    #I call this the Big Ugly
    Apprentice.Server.start_link(update_files(paths), fn
      changed, manifest ->
        loaded = Enum.map changed, fn ({file_name, _}) ->
            case file_name =~ %r/_test.exs/ do
              true -> file_name
              _ ->
                test_for_file = "test#{Regex.run(%r/[^(lib)][^\.]+/, file_name)}_test.exs"
                manifest[test_for_file] && test_for_file
            end
        end
        loaded = Enum.filter(loaded, fn(x) -> x end)
        loaded = Enum.map loaded, fn(file) -> Code.load_file(file) end
        if Enum.any? loaded do
          case ExUnit.run do
            0 ->
              Enum.each manifest, fn({file, _}) ->
                if file =~ %r/_test.exs/ do
                  Code.load_file(file)
                end
              end
              ExUnit.run
            failures -> failures
          end
        end
    end)
    do_run(paths)
  end

  def update_files(paths) do
    extract_file_paths(paths) |> with_modified_times
  end

  defp do_run(paths) do
    receive do
      { _, _ } ->
        new_manifest = update_files(paths)
        Apprentice.Server.update_files(new_manifest)
    end
    do_run(paths)
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
