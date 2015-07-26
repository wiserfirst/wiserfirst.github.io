require "jekyll-import"

JekyllImport::Importers::WordpressDotCom.run({
  "source" => "/Users/wiser/Downloads/peacefulrevolution.wordpress.2015-07-26.xml",
  "no_fetch_images" => false,
  "assets_folder" => "assets"
})
