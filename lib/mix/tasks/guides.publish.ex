defmodule Mix.Tasks.Guides.Publish do
  use Mix.Task

  @bucket "phoenixframework.org"
  @blog_prefix "build/blog--"

  @doc "Publishes guides to S3"

  def run([]) do
    build_local_files()
    copy_assets()
    copy_index_files()
    copy_blog_files()
  end

  defp build_local_files do
    log "obelisk: building static files"
    Mix.Task.run("obelisk", ["build"])
  end

  defp copy_assets do
    log "s3: copying assets"
    System.cmd("aws",
      ~w(s3 cp build/assets s3://#{@bucket}/assets --acl public-read --recursive))
  end

  defp copy_index_files do
    for name <- Path.wildcard("build/*.{html,rss}") do
      log "s3: copying index file #{name}"
      s3_cp(name, Path.basename(name, ".html"), Path.extname(name))
    end
  end

  defp copy_blog_files() do
    for @blog_prefix <> name = full_name <- Path.wildcard(@blog_prefix <> "*") do
      basename = Path.basename(name, ".html")

      log "s3: publishing blog/#{basename}"
      s3_cp(full_name, "blog/#{basename}", ".html")
    end
  end

  defp s3_cp(name, s3_path, ".html") do
    System.cmd("aws", ["s3", "cp", name,
                       "s3://#{@bucket}/#{s3_path}",
                       "--content-type","text/html",
                       "--acl", "public-read"])
  end
  defp s3_cp(name, s3_path, _ext) do
    System.cmd("aws", ["s3", "cp", name,
                       "s3://#{@bucket}/#{s3_path}",
                       "--acl", "public-read"])
  end

  defp log(msg) do
    IO.puts ">> #{msg}"
  end
end
