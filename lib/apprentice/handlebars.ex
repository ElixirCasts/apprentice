defmodule Apprentice.Handlebars do
  @moduledoc """
    Currently requires node and a node ember precompiler

    OSX: Brew install node
         npm install -g ember-precompile
    Workshop file must define the following:
      "handlebars_template_paths" return List
      "handlebars_output_path" return String
  """

  def run do
    IO.puts "Your aprentice is watching your handlebars templates"
    paths = Apprentice.Workshop.handlebars_template_paths
    ports = Apprentice.watch(paths)
    Apprentice.Server.start_link Apprentice.update_files(paths, ["handlebars"]), :handlebars, fn
      changed, manifest -> on_change(changed, manifest)
    end
    do_run(paths, ports)
  end

  #TODO Change this to use erjang_js runtime
  def on_change(changed_files, all_files) do
    Enum.each changed_files, fn({file, _}) ->
      IO.puts "Your apprentice is compiling the template: #{file}"
      output_path = Apprentice.Workshop.handlebars_output_path
      template_name = Path.basename file, ".handlebars"
      System.cmd("ember-precompile #{file} -f #{output_path}/#{template_name}.js")
    end
  end

  defp do_run(paths, ports) do
    receive do
      { port, _ } ->
        if port in ports do
          new_manifest = Apprentice.update_files(paths, ["handlebars"])
          Apprentice.Server.update_files(new_manifest, :handlebars)
        end
        { :EXIT, _, reason } ->
        raise "No longer watching #{__MODULE__}. Reason: #{reason}"
    end
    do_run(paths, ports)
  end
end
