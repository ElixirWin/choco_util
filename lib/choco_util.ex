defmodule ChocoUtil do
  defmodule Package do
    defstruct url_template: "", current_version: "", binary_name: ""
  end

  defp get_sha256(file) do
    {result_string,0} = System.cmd("certutil",["-hashfile", "#{file}","SHA256"],[])
    [_,sha256,_,_] = String.split(result_string, "\r\n")
    sha256
  end

  defp get_file_from_remote(filename, url) do
    Application.ensure_all_started :inets 
    :ssl.start
    {:ok, resp} = :httpc.request(:get, {url, []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp

    File.write!(filename, body) 
  end

  def get_file_and_sha256(version) do
    precompiled_zip = System.get_env("temp")<>"\\precompiled.zip"
    remote_url = 'https://github.com/elixir-lang/elixir/releases/download/v#{version}/Precompiled.zip'
    get_file_from_remote(precompiled_zip, remote_url)
    sha256 = get_sha256(precompiled_zip)
    sha256
  end

  def initialize_packages do
    elixir_package = %Package{
      url_template: ~S('https://github.com/elixir-lang/elixir/releases/download/v#{version}/Precompiled.zip'),
      current_version: "1.5.2",
      binary_name: "precompiled.zip"
    }
  end
end
