defmodule Mix.Tasks.Guides.Build do
  use Mix.Task

  @blog_prefix "docs/blog--"

  @doc "Build guides"

  def run([]) do
    build_local_files()
    File.rm_rf("docs")
    minify_css()
    copy_assets()
    copy_blog_files()
  end

  defp build_local_files do
    log "obelisk: building static files"
    Mix.Task.run("obelisk", ["build"])
  end

  defp minify_css() do
    purify = System.cmd("purifycss", ["build/assets/css/base.css",
      "build/*.html"])

    case purify do
      {output, 0} -> File.write!("build/assets/css/base.css", output)
      _ -> nil
    end
  end

  defp copy_assets() do
    log "build: copying assets"
    File.mkdir_p("docs")
    File.cp_r("build", "docs")
    File.rename("docs/assets/favicon.ico", "docs/favicon.ico")
  end

  defp copy_blog_files() do
    File.mkdir_p("docs/blog")
    (@blog_prefix <> "*")
    |> Path.wildcard()
    |> Enum.each(fn @blog_prefix <> name = full_name ->
      basename = Path.basename(name, ".html")

      log "build: moving blog/#{basename}"
      File.rename(full_name, "docs/blog/#{basename}.html")
    end)
  end

  defp log(msg) do
    IO.puts ">> #{msg}"
  end
end
