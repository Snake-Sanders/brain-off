defmodule Mix.Tasks.Gen.HtmlTest do
  use ExUnit.Case
  # alias Mix.Tasks.Gen.Html
  # doctest Tools

  test "simple conversion from markdown to html" do
    html = "<p>\nHello&lt;br /&gt;World</p>\n"
    markdown = "Hello<br />World"

    assert Mix.Tasks.Gen.Html.parse(markdown) == {:ok, html, []}
  end

  describe "convert a markdown file to html" do
    test "parsing is correct" do
      md_file = "./test/inputs/markdown/demo3.md"

      {:ok, html_doc, deprecation_messages} = Mix.Tasks.Gen.Html.convert_file(md_file)

      assert String.starts_with?(html_doc, "<h1>\ntable of content</h1>")
      assert deprecation_messages == []
    end

    test "parsing a file list" do
      md_files = [
        "./test/inputs/markdown/demo1.md",
        "./test/inputs/markdown/demo2.md",
        "./test/inputs/markdown/demo3.md"
      ]

      # each element in the list is of the type: 
      # {:ok, html_docs, deprecation_messages}
      # filter only the :ok of each element in the list
      # check that all went ok, all are true
      html_list =
        md_files
        |> Mix.Tasks.Gen.Html.convert_files!()

      # |> Enum.map(fn {:ok, _html, _deprec} -> true end)
      # |> Enum.all?()

      assert length(html_list) == 3
    end

    # In order to run this test, I need to find an example of deprecated markdown.
    @tag :skip
    test "parsing is incorrect" do
      md_file = "./test/inputs/markdown/wrong.md"

      {:ok, html_doc, deprecation_messages} = Mix.Tasks.Gen.Html.run(md_file)

      assert html_doc != nil
      assert deprecation_messages == []
    end
  end
end
