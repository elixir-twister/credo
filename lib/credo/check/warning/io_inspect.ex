defmodule Credo.Check.Warning.IoInspect do
  @moduledoc """
  While calls to IO.inspect might appear in some parts of production code,
  most calls to this function are added during debugging sessions.

  This check warns about those calls, because they might have been committed
  in error.
  """

  @explanation [check: @moduledoc]
  @call_string "IO.inspect"

  use Credo.Check, base_priority: :high

  def run(%SourceFile{} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.traverse(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({{:., _, [{:__aliases__, _, [:IO]}, :inspect]}, meta, _arguments} = ast, issues, issue_meta) do
    {ast, issues_for_call(meta, issues, issue_meta)}
  end
  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  def issues_for_call(meta, issues, issue_meta) do
    [issue_for(meta[:line], @call_string, issue_meta) | issues]
  end

  defp issue_for(line_no, trigger, issue_meta) do
    format_issue issue_meta,
      message: "There should be no calls to IO.inspect/1.",
      trigger: trigger,
      line_no: line_no
  end
end