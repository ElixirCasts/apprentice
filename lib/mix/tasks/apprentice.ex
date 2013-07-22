defmodule Mix.Tasks.Apprentice do
  use Mix.Task

  @shortdoc "Have your apprentice watch your files"

  @moduledoc """
    Takes an option path to your workshop file otherwise it points to
    workshop.exs at your project's root
    Your apprentice will watch your files and run some code(tests)
  """
  def run(options) do
    workshop_path = options[0] || "workshop.exs"
    Mix.Task.run 'app.start'
    Code.require_file(workshop_path)
    Apprentice.run Apprentice.Workshop.apprentices
  end

  defmodule Install do
    @shortdoc "Install the workshop.exs template"

    def run(_) do
      IO.puts "Copying workshop.exs to you project root"
      File.cp! "#{__DIR__}/../../../workshop.exs", "workshop.exs"
      IO.puts "Your apprentice is ready to work. Just edit your workshop file
      and mix apprentice"
    end
  end
end