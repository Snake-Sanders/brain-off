defmodule Mix.Tasks.Gen.Html do
  @shortdoc "generate HTML pages out of Markdown"

  @moduledoc """
  This task reads the markdown files and generates HTML pages
  The module can be run as a mix task

  To get this information from the console use the help option:

  `mix help gen.html`

  see: https://hexdocs.pm/mix/1.12/Mix.Task.html
  """

  use Mix.Task
  require Earmark

  # def run({src: src_path, dst: dst_path}) do
  #   Earmark.from_file!(md_file)
  # end

  def run(_) do
    # path to directory to search for input files
    src_path = "./test/inputs/markdown/"
    dst_path = "./test/output/markdown/"

    # sanity check, take only markdown files
    # todo use: Path.wildcard("./*.md") -> [file.md, file2.md,...]
    md_files =
      src_path
      |> File.ls!()
      |> Enum.reject(fn file -> File.dir?(file) end)
      |> Enum.reject(fn file -> Path.extname(file) != ".md" end)

    html_code =
      md_files
      |> Enum.map(fn file -> src_path <> file end)
      |> convert_files!()

    # create the output dir
    if not File.dir?(dst_path) or
         not File.exists?(dst_path) do
      File.mkdir_p!(dst_path)
    end

    # html_files =
    md_files
    |> Enum.map(fn file ->
      dst_path <> String.replace_trailing(file, ".md", ".html")
    end)
    |> Enum.zip(html_code)
    |> Enum.each(fn {f_path, code} ->
      File.write(f_path, code)
    end)

    # html_files
  end

  @doc """
  This parses a markdown code block to HTML code
  `md_code` is the markdown string code
  """
  def parse(md_code) when is_bitstring(md_code) do
    Earmark.as_html(md_code, [])
  end

  @doc """
  Opens a markdown file from the `path` argument

  return:
    {:ok, html_doc, []}                  
    {:ok, html_doc, deprecation_messages}
    {:error, html_doc, error_messages}   
  """
  def convert_file(path) when is_bitstring(path) do
    path
    |> Path.absname()
    |> File.read!()
    |> Earmark.as_html()
  end

  @doc """
  Opens a list of markdown files and convert the content to HTML.
  It calls `convert_file()`
  """
  def convert_files!(paths) when is_list(paths) do
    paths
    |> Enum.map(fn p -> convert_file(p) end)
    |> Enum.map(fn {:ok, html_content, _deprec} -> html_content end)
  end
end
