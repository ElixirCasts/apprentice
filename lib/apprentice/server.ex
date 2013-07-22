defmodule Apprentice.Server do
  use GenServer.Behaviour

  #########
  # External API

  def start_link(file_manifest, server, func) do
    :gen_server.start_link({ :local, server }, __MODULE__, {file_manifest, func }, [])

    file_manifest
  end

  def update_files(new_manifest, server) do
    :gen_server.cast server, { :updated_files, new_manifest }
  end

  #########
  # Genserver implementation

  def init(file_manifest) do
    { :ok, file_manifest }
  end

  def handle_cast({ :updated_files, new_manifest }, { current_manifest, func }) do
    func.(updated_files(current_manifest, new_manifest), new_manifest)
    { :noreply, { new_manifest, func} }
  end

  defp updated_files(current, new) do
    Enum.filter new, fn({ path, new_date }) ->
      case current[path] do
        nil -> true
        old_date -> new_date != old_date
      end
    end
  end
end
