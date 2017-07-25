defmodule Mix.Tasks.Guides.Publish do
  use Mix.Task

  @bucket "phoenixframework.org"
  @blog_prefix "build/blog--"

  @doc "Publishes guides to S3"

  def run([]) do
    build_local_files()
    copy_assets()
    copy_blog_files()
  end

  defp build_local_files do
    log "obelisk: building static files"
    Mix.Task.run("obelisk", ["build"])
  end

  defp copy_assets do
    IO.puts "s3: copying assets"
    System.cmd("aws",
      ~w(s3 cp build/assets s3://#{@bucket}/assets --acl public-read --recursive))
  end

  defp copy_blog_files() do
    for @blog_prefix <> name = full_name <- Path.wildcard(@blog_prefix <> "*") do
      basename = Path.basename(name, ".html")

      log "s3: publishing blog/#{basename}"
      System.cmd("aws", ["s3", "cp", full_name,
                         "s3://#{@bucket}/blog/#{basename}",
                         "--content-type",
                         "text/html",
                         "--acl",
                         "public-read"])
    end
  end

  defp log(msg) do
    IO.puts ">> #{msg}"
  end
end
