Code.require_file "../test_helper.exs", __DIR__

defmodule ApprenticeServerTest do
  use ExUnit.Case

  test "returns multiple files" do
    mock_files = [{ "no_op/file_path", { { 1, 2, 3 }, { 4, 5, 6 } } },
                  { "no_op/not_changed", { { 1, 2, 3 }, { 4, 5, 6 } } }]
    Apprentice.Server.start_link(mock_files, fn -> :noop end, :test)
    new_manifest = [{ "no_op/file_path", { { 1, 2, 3 }, { 4, 5, 7 } } },
                    { "no_op/not_changed", { { 1, 2, 3 }, { 4, 5, 6 } } },
                    { "no_op/new", { { 1, 2, 3 }, { 4, 5, 6 } } }]

    assert Apprentice.Server.update_files(new_manifest, :test) == :ok
  end
end
