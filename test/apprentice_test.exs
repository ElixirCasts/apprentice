Code.require_file "test_helper.exs", __DIR__

defmodule ApprenticeTest do
  use ExUnit.Case

  test "starts fswatch as a port" do
    assert is_port Apprentice.watcher
  end

  setup do
    File.mkdir "test/tmp"
    File.touch! "test/tmp/foo.test"
    File.touch! "test/tmp/bar.test"
    :ok
  end

  test "takes an inventory of the directory" do
    assert "test/tmp/bar.test" in Apprentice.extract_file_paths(["test/tmp"], ["test"])
  end

  test "returns files with last moddified times" do
    file_paths = Apprentice.extract_file_paths(["test/tmp"], ["test"])
    { _path, date } = Enum.first(Apprentice.with_modified_times(file_paths))
    assert is_tuple date
  end

  teardown do
    { :ok, File.rm_rf! "test/tmp" }
  end

  def with_modified_time(path) do
    {date, { hour, min, sec }} = File.stat!(path).mtime
    { path,  {date, { hour, min, sec - 1}}}
  end

  def with_current_time(path) do
    { path, File.stat!(path).mtime }
  end
end
