defmodule Mix.Tasks.Guides.Publish do
  use Mix.Task

  @bucket "phoenixframework.org"
  @blog_prefix "build/blog--"

  @doc "Publishes guides to S3"

  def run([]) do
    copy_blog_files()
  end

  defp copy_blog_files() do
    for @blog_prefix <> name = full_name <- Path.wildcard(@blog_prefix <> "*") do
      basename = Path.basename(name, ".html")


      IO.puts ">> Publishing blog/#{basename}"
      System.cmd("aws", ["s3", "cp", full_name,
                         "s3://#{@bucket}/blog/#{basename}",
                         "--content-type",
                         "text/html",
                         "--acl",
                         "public-read"])
    end
  end
end
