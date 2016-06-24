defmodule OfflineAsset do
  def css(opts) do
    if opts[:url] do
      "<link href='#{(opts[:url])}', media='#{opts[:media] || "all"}', rel='stylesheet', type='text/css'></link>"
    else
      if opts[:inline] do
        css_inline(opts)
      else
        css_file(opts)
      end
    end
  end

  def js(opts) do
    if opts[:url] do
      "<script src='#{(opts[:url])}></script>"
    else
      if opts[:inline] do
        js_inline(opts)
      else
        js_file(opts)
      end
    end
  end

  defp css_file(opts) do
    "<link href='#{opts[:static_path]}', media='#{opts[:media] || "all"}', rel='stylesheet', type='text/css'></link>"
  end

  defp css_inline(opts) do
    "<style>#{(File.read!(Path.join([opts[:file_path]])))}</style>"
  end

  defp js_file(opts) do
    "<script src='#{opts[:static_path]}'></script>"
  end

  defp js_inline(opts) do
    "<script type='text/javascript' async='async'>#{(File.read!(Path.join([opts[:file_path]])))}</script>"
  end
end
