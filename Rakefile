desc "compile and run the site"

task :jekyll_build do
  system('bundle exec jekyll build')
  require 'html/proofer'
  HTML::Proofer.new("./_site").run
end

task :default do
  pids = [
    spawn("bundle exec jekyll server -w"),
    spawn("scss --watch _assets:stylesheets"),
    spawn("coffee -b -w -o javascripts -c _assets/*.coffee")
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  loop do
    sleep 1
  end
end
