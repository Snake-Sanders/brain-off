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
  require EEx

  # records parsing errors, see log_issue/0
  @issue_recorder []

  @doc """
  Main entry point for execution, uses default parameterss
  """
  def run(_) do
    src_path = "./user/markdown/"
    dst_path = "./user/web/"

    run(src_path, dst_path)
  end

  @doc """
  Searches for markdown files and converts them to HTML files

  ## Parameters

  - src_path: directory path to search for input markdown files
  - dst_path: directory path to write the generated html files
  """
  def run(src_path, dst_path) do
    # create the output dir if it does not exist
    create_dir(dst_path)

    page_layout = "./lib/template/page.html.eex"

    html_files =
      "#{src_path}*.md"
      |> Path.wildcard()
      |> convert_files!(page_layout)
      |> Enum.filter(fn {status, _file, _content} -> status == :ok end)
      |> Enum.map(fn {:ok, md_file, html_content} ->
        write_out_html_file({md_file, html_content}, dst_path)
      end)

    # create page index with files name as title
    # and the file location as href link
    file_index = make_page_index(html_files)
    navbar = load_navbar("#{src_path}../navbar.json")
    index_layout = "./lib/template/layout.html.eex"
    layout_code = EEx.eval_file(index_layout, titels_href: file_index, navbar: navbar)
    File.write(dst_path <> "index.html", layout_code)

    copy_resources("#{src_path}img", "#{dst_path}img")
    copy_resources("./assets/css", "#{dst_path}css")
    copy_resources("./assets/js", "#{dst_path}js")
    log_issue()
  end

  @doc """
  Converts a markdown code block to HTML code

  ## Parameters

  - md_code: it is the markdown string code

  ## Example

      iex> markdown = "Hello<br />World"
      iex> Mix.Tasks.Gen.Html.parse(markdown)
      "<p>\nHello&lt;br /&gt;World</p>\n"

  """
  def parse(md_code) when is_bitstring(md_code) do
    Earmark.as_html(md_code, [])
  end

  @doc """
  Converts a markdown file to HTML

  Opens a markdown file from the `path` argument
  and returns the content in HTML format

  ## Parameters

  - path: Markdown file path

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

  # Opens a list of markdown files and convert the content to HTML.
  # The content is injected in the HTML template
  # It calls `convert_file()`
  #
  ## Parameters
  #
  # - dir_path: path to a directory
  # - page_layout: path to `page_layout.html.eex` file
  #
  # returns [list_html_content, parsing_error_information]

  def convert_files!(paths, page_layout) when is_list(paths) do
    for path <- paths do
      file_name = Path.basename(path)

      # convert markdown to html body
      case convert_file(path) do
        {:ok, html_content, _deprec} ->
          # injects the html body into the template layout
          html_page = EEx.eval_file(page_layout, page_content: html_content)
          {:ok, file_name, html_page}

        warn_msg ->
          rec_issue(file_name, warn_msg)
          {:error, file_name, warn_msg}
      end
    end
  end

  # `warn_list` is of the type [{:warning, line_numb, err_message}, {...}]
  defp rec_issue(file, {:error, _contetn, warn_list} = _warn_msg) do
    @issue_recorder ++ [{file, warn_list}]
  end

  # Error messages from Markdown files which failed to be parsed are stored in
  # a global variable @issue_recorder
  defp log_issue() do
    if length(@issue_recorder) > 0 do
      IO.puts("Failed parsing the files")

      @issue_recorder
      |> Enum.each(fn {file, warn_list} ->
        IO.puts("#{file}:")

        Enum.each(warn_list, &print_file_warns/1)
      end)
    end
  end

  # Prints the list of warning messages detected when parsing a markdown file
  # The format of the function parameter is as it is defined by Earmark
  defp print_file_warns({err_level, line_numb, msg}) do
    IO.puts("[#{err_level}] #[#{line_numb}]: #{msg}")
  end

  # check if a directory path is valid
  #
  ## Parameters
  #
  # - dir_path: path to a directory
  defp is_valid_dir(dir_path) do
    File.dir?(dir_path) and File.exists?(dir_path)
  end

  # Writes out html file into the destination path `dst_path`
  # Files with parsing errors are not written just logged as info
  #
  ## Parameters
  #
  # - data_list: list of {parse_status, file_name, html_code}
  defp write_out_html_file({file_name, html_code}, dst_path) do
    file_path = dst_path <> String.replace_trailing(file_name, ".md", ".html")
    File.write(file_path, html_code)
    file_path
  end

  defp copy_resources(src_path, dst_path) do
    if File.dir?(src_path) do
      File.cp_r(src_path, dst_path)
    end
  end

  defp make_page_index(html_files) do
    html_files
    |> Enum.map(fn path ->
      get_title_from_file_path(path)
    end)
  end

  # given a file path, it converts the file name to be used
  # as table of content item, replacing delimiter symbols
  # and capitalizing the final titel
  defp get_title_from_file_path(file_path) do
    href = "./" <> Path.basename(file_path)

    titel =
      Path.basename(file_path, ".html")
      |> String.replace(["-", "_"], " ")
      |> String.capitalize()

    {titel, href}
  end

  defp create_dir(path) do
    if not is_valid_dir(path) do
      case File.mkdir_p!(path) do
        :ok ->
          true

        {error, reason} ->
          IO.puts("Failed creating output dir #{path}.\n#{error}: #{reason}")
      end
    end
  end

  defp load_navbar(path_json) do
    if File.exists? path_json do
      path_json
      |> File.read!
      |> Jason.decode!
      |> Map.to_list
    else
      %{}
    end
  end
end
