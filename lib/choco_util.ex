defmodule ChocoUtil do
  def get_sha256(file) do
    {result_string,0} = System.cmd("certutil",["-hashfile", "#{file}","SHA256"],[])
    [_,sha256,_,_] = String.split(result_string, "\r\n")
    sha256
  end

  def get_file_from_remote(filename, url) do
    Application.ensure_all_started :inets 
    :ssl.start
    {:ok, resp} = :httpc.request(:get, {url, []}, [], [body_format: :binary])
    {{_, 200, 'OK'}, _headers, body} = resp

    File.write!(filename, body) 
  end
end
