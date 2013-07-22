defmodule Mix.Tasts.Apprentice.Install do
  @shortdoc "Install the workshop.exs template"

  def run(_) do
    IO.puts "Copying workshop.exs to you project root"
    File.cp! "#{__DIR__}/../../../workshop.exs", "workshop.exs"
    IO.puts "Your apprentice is ready to work. Just edit your workshop file
    and mix apprentice"
  end
end
