defmodule Mix.Tasks.Gen.HtmlTest do
  use ExUnit.Case, async: true
  require Floki

  doctest Tools

  setup do
    {:ok, in_p: "./test/inputs/markdown/", out_p: "./test/output/markdown/"}
  end

  test "simple conversion from markdown to html" do
    html = "<p>\nHello&lt;br /&gt;World</p>\n"
    markdown = "Hello<br />World"

    assert Mix.Tasks.Gen.Html.parse(markdown) == {:ok, html, []}
  end

  test "parsing a correct file", %{in_p: in_p} = _ctx do
    md_file = in_p <> "demo3.md"

    {:ok, html_doc, deprecation_messages} = Mix.Tasks.Gen.Html.convert_file(md_file)

    assert String.starts_with?(html_doc, "<h1>\ntable of content</h1>")
    assert deprecation_messages == []
  end

  test "parsing a md file with code blocks", %{in_p: in_p} = _ctx do
    md_file = in_p <> "demo5.md"
    {:ok, html_doc, deprecation_messages} = Mix.Tasks.Gen.Html.convert_file(md_file)
    assert deprecation_messages == []

    # using Floki to parse html
    {:ok, doc} = Floki.parse_document(html_doc)

    # there should be 3 code blocks
    pre_items = Floki.find(doc, "pre")
    assert length(pre_items) == 3

    code_items = Floki.find(doc, "code")
    assert length(code_items) == 3
  end

  # @tag :skip
  test "parsing an incorrect file", %{in_p: in_p} = _ctx do
    md_file = in_p <> "wrong.md"

    {:error, _html_doc, [{:warning, _line, deprecation_messages}]} =
      Mix.Tasks.Gen.Html.convert_file(md_file)

    assert "Closing unclosed backquotes ` at end of input" == deprecation_messages
  end

  test "parsing a file list", %{in_p: in_p} = _ctx do
    # create file paths
    md_files =
      ["demo1.md", "demo2.md", "demo3.md"]
      |> Enum.map(fn f -> in_p <> f end)

    # todo move this to config
    page_layout = "./lib/template/page.html.eex"

    # each element in the list is of the type:
    # {:ok, html_docs, deprecation_messages}
    # filter only the :ok of each element in the list
    # check that all went ok, all are true
    html_list =
      md_files
      |> Mix.Tasks.Gen.Html.convert_files!(page_layout)

    assert length(html_list) == 3

    all_passed =
      html_list
      |> Enum.map(fn {:ok, _html, _deprec} -> true end)
      |> Enum.all?()

    assert all_passed
  end

  test "parsing a directory", %{in_p: in_p, out_p: out_p} = _ctx do
    # clean output
    case File.rm_rf(out_p) do
      # cleared dirs ok
      {:ok, _del_files} -> true
      {:error, reason, file} -> IO.puts("failed deleting #{file}: #{reason}")
      _ -> IO.puts("?")
    end

    Mix.Tasks.Gen.Html.run(in_p, out_p)

    # check that the output dir was created
    assert File.dir?(out_p) and File.exists?(out_p)

    # expecting that the amount of markdown files in the input dir
    # is the same as the html files generated in output dir
    # to check the exact number html files we need to know how many conversions have failed.
    # therefore at this point we just check there are at least one html file
    assert length(Path.wildcard("#{out_p}*.html")) > 0

    # if there are images to be copied, make sure that at least those demo imgs are copied
    # the other images are favicon, brain.png, etc.
    img_p = "#{in_p}img"

    if File.dir?(img_p) do
      {:ok, demo_imgs} = File.ls(img_p)
      {:ok, copied_imgs} = File.ls("#{out_p}img")
      output_imgs = copied_imgs -- demo_imgs
      assert length(output_imgs) > 0
    end

    idx_html = out_p <> "index.html"
    assert File.exists?(idx_html)
  end
end
