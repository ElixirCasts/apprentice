defmodule Mix.Tasks.Apprentice do
  use Mix.Task

  @shortdoc "Have your apprentice watch your files"

  @moduledoc """
    Takes an option path to your workshop file otherwise it points to
    workshop.exs at your project's root
    Your apprentice will watch your files and run some code(tests)
  """
  def run(path) do
    path = path || "workshop.exs"
    IO.puts Enum.any? path
    Apprentice.run { ["test", "lib"], "*_test.exs" }
  end
end