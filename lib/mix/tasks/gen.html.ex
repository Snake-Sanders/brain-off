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
    if not is_valid_dir(dst_path) do
      case File.mkdir_p!(dst_path) do
        :ok ->
          true

        {error, reason} ->
          IO.puts("Failed creating output dir. #{error}: #{reason}")
      end
    end

    "#{src_path}*.md"
    # search for md files
    |> Path.wildcard()
    |> convert_files!()
    |> Enum.each(fn item ->
      write_out_converted_files(item, dst_path)
    end)

    copy_images("#{src_path}img", "#{dst_path}img")
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

  @doc """
  Opens a list of markdown files and convert the content to HTML.
  It calls `convert_file()`
  returns [list_html_content, parsing_error_information]
  """
  def convert_files!(paths) when is_list(paths) do
    for path <- paths do
      file_name = Path.basename(path)

      case convert_file(path) do
        {:ok, html_content, _deprec} -> {:ok, file_name, html_content}
        warn_msg -> {:error, file_name, warn_msg}
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

  # Writes out html files inro the destination path `dst_path`
  # Files with parsing errors are not written just logged as info
  #
  ## Parameters
  #
  # - data_list: list of {parse_status, file_name, html_code}
  defp write_out_converted_files(data_list, dst_path) do
    case data_list do
      {:ok, file, content} ->
        (dst_path <> String.replace_trailing(file, ".md", ".html"))
        |> File.write(content)

      {:error, file, warn_msg} ->
        rec_issue(file, warn_msg)
    end
  end

  defp copy_images(src_path, dst_path) do
    if File.dir?(src_path) do
      File.cp_r(src_path, dst_path)
    end
  end
end
