defmodule ChocoUtil do
  @elixir_package_name "Elixir"
  @erlang_x86_package_name "Erlang_x86"
  @erlang_x64_package_name "Erlang_x64"
  @rebar_package_name "Rebar3"
  @file_separator  "."
  @eex_extension "eex"

  defp initialize_package(@elixir_package_name) do
    elixir_package = %Package{
      url_template: 'https://github.com/elixir-lang/elixir/releases/download/v1.5.2/Precompiled.zip',
      current_version: "1.5.2",
      binary_name: "/precompiled.zip",
      template_dir: System.get_env("UserProfile") <> "/choco_util/lib/templates/elixir"
    }
    elixir_package
  end  
    
  defp initialize_package(@rebar_package_name) do
    rebar3_package = %Package{
      url_template: 'https://s3.amazonaws.com/rebar3/rebar3',
      current_version: "3.4.4",
      binary_name: "/rebar3",
      template_dir: System.get_env("UserProfile") <> "/choco_util/lib/templates/rebar"
    }
    rebar3_package
  end

  defp initialize_package(@erlang_x86_package_name) do
    erlang_w32_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win32_20.1.exe',
      current_version: "20.1",
      current_erts_version: "9.1",
      binary_name: "/opt_win32_20.1.exe",
      template_dir: System.get_env("UserProfile") <> "/choco_util/lib/templates/erlang"
    }
    erlang_w32_package
  end


  defp initialize_package(@erlang_x64_package_name) do
    erlang_w64_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win64_20.1.exe',
      current_version: "20.1",
      current_erts_version: "9.1",
      binary_name: "/opt_win64_20.1.exe",
      template_dir: System.get_env("UserProfile") <> "/choco_util/lib/templates/erlang"
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

  defp filter_file_list(file_list) do
    for f <- file_list, [_base, _extension, @eex_extension] <- String.split(f,@file_separator), do: f
  end

  defp get_base_file_name_from_template_name(template_file_name) do
    [base, extension, @eex_extension] = String.split(template_file_name,@file_separator)
    base <> @file_separator <> extension
  end

  def fix_up(pn) do
    package_details = initialize_package(pn)
    original_dir = File.cwd()
    package_dir = package_details.template_dir
    File.cd package_dir
    {:ok,file_list} = File.ls()
    filtered_file_list = filter_file_list(file_list)
    for f <- filtered_file_list do
      File.write(package_dir <> "/" <> get_base_file_name_from_template_name(f), EEx.eval_file(f))
    end
    File.cd original_dir
  end

  def get_file_and_sha256(pn) do
    package_details = initialize_package(pn)
    download_directory = package_details.download_directory
    filename = package_details.binary_name
    remote_url = package_details.url_template
    get_file_from_remote(download_directory, filename, remote_url)
    get_sha256(download_directory <> filename)
  end

  # def get_file_and_sha256(pn = @rebar_package_name) do
  #   package_details = initialize_package(pn)
  #   download_directory = package_details.download_directory
  #   filename = package_details.binary_name
  #   remote_url = package_details.url_template
  #   get_file_from_remote(download_directory, filename, remote_url)
  #   get_sha256(download_directory <> filename)
  # end

  # def get_file_and_sha256(pn = @erlang_x86_package_name) do
  #   package_details_x86 = initialize_package(pn)
  #   download_directory = package_details_x86.download_directory
  #   filename = package_details_x86.binary_name
  #   remote_url = package_details_x86.url_template
  #   get_file_from_remote(download_directory, filename, remote_url)
  #   get_sha256(download_directory <> filename)
  # end
 
  # def get_file_and_sha256(pn = @erlang_x64_package_name) do
  #   package_details_x64 = initialize_package(pn)
  #   download_directory = package_details_x64.download_directory
  #   filename = package_details_x64.binary_name
  #   remote_url = package_details_x64.url_template
  #   get_file_from_remote(download_directory, filename, remote_url)
  #   get_sha256(download_directory <> filename)
  # end

  def get_current_version(pn) do
    p = initialize_package(pn)
    p.current_version
  end

  def get_current_erts_version(pn) do
    p = initialize_package(pn)
    p.current_erts_version
  end 

end