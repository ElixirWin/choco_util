defmodule ChocoUtil do
  @elixir_package_name "Elixir"
  @elixir_ver "1.5.3"
  @erlang_x86_package_name "Erlang_x86"
  @erlang_x64_package_name "Erlang_x64"
  @erlang_ver "20.2"
  @rebar_package_name "Rebar3"
  @rebar_ver "3.5.0"
  @file_separator  "."
  @eex_extension "eex"
  @base_template_dir System.get_env("UserProfile") <> "/choco_util/lib/templates/"
  
  defp initialize_package(@elixir_package_name) do
    elixir_package = %Package{
      url_template: 'https://github.com/elixir-lang/elixir/releases/download/v#{@elixir_ver}/Precompiled.zip',
      current_version: "#{@elixir_ver}",
      binary_name: "/precompiled.zip",
      template_dir: @base_template_dir <> "elixir"
    }
    elixir_package
  end  
    
  defp initialize_package(@rebar_package_name) do
    rebar3_package = %Package{
      url_template: 'https://s3.amazonaws.com/rebar3/rebar3',
      current_version: "#{@rebar_ver}",
      binary_name: "/rebar3",
      template_dir: @base_template_dir <> "rebar"
    }
    rebar3_package
  end

  defp initialize_package(@erlang_x86_package_name) do
    erlang_w32_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win32_#{@erlang_ver}.exe',
      current_version: "#{@erlang_ver}",
      current_erts_version: "9.2",
      binary_name: "/otp_win32_#{@erlang_ver}.exe",
      template_dir: @base_template_dir <> "erlang"
    }
    erlang_w32_package
  end


  defp initialize_package(@erlang_x64_package_name) do
    erlang_w64_package = %Package{
      url_template: 'http://www.erlang.org/download/otp_win64_#{@erlang_ver}.exe',
      current_version: "#{@erlang_ver}",
      current_erts_version: "9.2",
      binary_name: "/otp_win64_#{@erlang_ver}.exe",
      template_dir: @base_template_dir <> "erlang"
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
    file_list 
    |> Enum.filter(fn(file) -> String.ends_with?(file,@eex_extension) end)
  end

  defp get_base_file_name_from_template_name(template_file_name) do
    [base, extension, @eex_extension] = String.split(template_file_name,@file_separator)
    base <> @file_separator <> extension
  end

  def generate_cng_files(pn) do
    package_details = initialize_package(pn)
    {:ok,original_dir} = File.cwd()
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

  def get_current_version(pn) do
    p = initialize_package(pn)
    p.current_version
  end

  def get_current_erts_version(pn) do
    p = initialize_package(pn)
    p.current_erts_version
  end 

end