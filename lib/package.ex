  defmodule Package do
    defstruct url_template: "", current_version: "", download_directory: System.get_env("temp"), binary_name: ""
  end
