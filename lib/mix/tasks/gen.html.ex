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

  def run(_) do
    IO.puts "Generating html pages"
  end

end