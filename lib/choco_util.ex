defmodule ChocoUtil do
  @elixir_package_name "Elixir"
  @erlang_x86_package_name "Erlang_x86"
  @erlang_x64_package_name "Erlang_x64"
  @rebar_package_name "Rebar3"

  defp initialize_package(@elixir_package_name) do
    elixir_package = %Package{
      url_template: 'https://github.com/elixir-lang/elixir/releases/download/v1.5.2/Precompiled.zip',
      current_version: "1.5.2",
      binary_name: "/precompiled.zip"
    }
    elixir_package
  end  
    
  defp initialize_package(@rebar_package_name) do
    rebar3_package = %Package{
      url_template: 'https://s3.amazonaws.com/rebar3/rebar3',
      current_version: "3.4.4",
      binary_name: "/rebar3"
    }
    rebar3_package
  end

  defp initialize_package(@erlang_package_name_x86) do
    erlang_w32_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win32_20.1.exe',
      current_version: "20.1",
      binary_name: "/opt_win32_20.1.exe"
    }
    erlang_w32_package
  end


  defp initialize_package(@erlang_package_name_x64) do
    erlang_w64_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win64_20.1.exe',
      current_version: "20.1",
      binary_name: "/opt_win64_20.1.exe"
    }
    erlang_w64_package
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

  def get_file_and_sha256(package_details = initialize_package(@elixir_package_name)) do
    download_directory = package_details.download_directory
    filename = package_details.binary_name
    remote_url = package_details.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    sha256 = get_sha256(download_directory <> filename)
    sha256
  end

  def get_file_and_sha256(package_details = initialize_package(@rebar_package_name)) do
    download_directory = package_details.download_directory
    filename = package_details.binary_name
    remote_url = package_details.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    sha256 = get_sha256(download_directory <> filename)
    sha256
  end

  def get_file_and_sha256(package_details_x86 = initialize_package(@erlang_package_name_x86)) do
    download_directory = package_details_x86.download_directory
    filename = package_details_x86.binary_name
    remote_url = package_details_x86.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    sha256 = get_sha256(download_directory <> filename)
    sha256
  end
 
  def get_file_and_sha256(package_details_x64 = initialize_package(@erlang_package_name_x64)) do
    download_directory = package_details_x64.download_directory
    filename = package_details_x64.binary_name
    remote_url = package_details_x64.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    sha256 = get_sha256(download_directory <> filename)
    sha256
  end

  def get_current_version(@elixir_package_name) do
    p = initialize_package(@elixir_package_name)
    p.current_version
  end

  def get_current_version(@erlang_package_name) do
    p = initialize_package(@erlang_package_name_x86)
    # Assume that x86 and x64 versions will always be the same
    p.current_version
  end

  def get_current_version(@rebar_package_name) do
    p = initialize_package(@rebar_package_name)
    p.current_version
  end

  def get_package_and_sha256() do 
    for p <- initialize_packages() do 
      get_file_and_sha256(p)
    end
  end    
end
