defmodule OfflineAsset do
  def css(opts) do
    if opts[:url] do
      "<link href='#{(opts[:url])}', media='#{opts[:media] || "all"}', rel='stylesheet', type='text/css'></link>"
    else
      if Mix.env != :dev do
        css_dev(opts)
      else
        css_other(opts)
      end
    end
  end

  def js(opts) do
    if opts[:url] do
      "<script src='#{(opts[:url])}></script>"
    else
      if Mix.env != :dev do
        js_dev(opts)
      else
        js_other(opts)
      end
    end
  end

  defp css_dev(opts) do
    "<link href='#{opts[:static_path]}', media='#{opts[:media] || "all"}', rel='stylesheet', type='text/css'></link>"
  end

  defp css_other(opts) do
    "<style>#{(File.read!(Path.join([opts[:file_path]])))}</style>"
  end

  defp js_dev(opts) do
    "<script src='#{opts[:static_path]}'></script>"
  end

  defp js_other(opts) do
    "<script type='text/javascript' async='async'>#{(File.read!(Path.join([opts[:file_path]])))}</script>"
  end
end
