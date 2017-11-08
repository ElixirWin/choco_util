defmodule ChocoUtil do
  defmodule Package do
    defstruct url_template: "", current_version: "", download_directory: System.get_env("temp"), binary_name: ""
  end

  defp initialize_packages do
    elixir_package = %Package{
      url_template: 'https://github.com/elixir-lang/elixir/releases/download/v1.5.2/Precompiled.zip',
      current_version: "1.5.2",
      binary_name: "/precompiled.zip"
    }
    
    rebar3_package = %Package{
      url_template: 'https://s3.amazonaws.com/rebar3/rebar3',
      current_version: "3.4.4",
      binary_name: "/rebar3"
    }

    erlang_w32_package = %Package{
      url_template: 'http://www.erlang.org/downloads/otp_win32_20.1.exe',
      current_version: "20.1",
      binary_name: "/opt_win32_20.1.exe"
    }

    erlang_w64_package = %Package{
      url_template: 'http://www.erlang.org/downloads/otp_win64_20.1.exe',
      current_version: "20.1",
      binary_name: "/opt_win64_20.1.exe"
    }
    [elixir_package, rebar3_package, erlang_w32_package, erlang_w64_package]
  end

  defp get_sha256(file) do
    {result_string,0} = System.cmd("certutil",["-hashfile", "#{file}","SHA256"],[])
    [_,sha256,_,_] = String.split(result_string, "\r\n")
    sha256
  end

  defp get_file_from_remote(download_dir, filename, url) do
    Application.ensure_all_started :inets 
    :ssl.start
    {:ok, resp} = :httpc.request(:get, {url, []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp

    File.write!(download_dir <> filename, body) 
  end

  def get_file_and_sha256(package_details = %Package{}) do
    download_directory = package_details.download_directory
    filename = package_details.binary_name
    remote_url = package_details.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    sha256 = get_sha256(download_directory <> filename)
    sha256
  end

  def get_package_and_sha256() do 
    for p <- initialize_packages() do 
      get_file_and_sha256(p)
    end
  end    
end
