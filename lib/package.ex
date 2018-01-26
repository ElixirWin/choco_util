defmodule Package do
  defstruct url_template: "",
            current_version: "",
            current_erts_version: nil,
            download_directory: System.get_env("temp"),
            binary_name: "",
            template_dir: nil
end
