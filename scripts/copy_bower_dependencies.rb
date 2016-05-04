# !!! Script must be run from root dir, e.g. "ruby scripts/(this).rb"

# This script copies dependencies out from the bower_components directory and
# modifies them slightly in preparation for being processed by Jekyll.
# Particularly, css files are renamed to appear like scss partials, so that our
# main scss file can import them.

require 'fileutils'

# Copy sass components

sass_dir = '_sass/third-party'
FileUtils.mkdir(sass_dir) if !File.exists?(sass_dir)
FileUtils.cp('bower_components/normalize-css/normalize.css', "#{sass_dir}/_normalize.scss")
FileUtils.cp('bower_components/pygments/css/igor.css',
"#{sass_dir}/_syntax-highlighting.scss")

terminal_style = File.open('bower_components/pygments/css/paraiso-dark.css', 'r').read
terminal_style = ".terminal * {

> pre {
    background-color: #000000;
    color: #ffffff;
}

#{terminal_style}
}"
File.open("#{sass_dir}/_terminal-syntax-highlighting.scss", 'w') { |file| file.write(terminal_style)}


fa_dir = "#{sass_dir}/font-awesome" # working directory, will remove later
FileUtils.mkdir(fa_dir) if !File.exists?(fa_dir)
FileUtils.cp_r('bower_components/font-awesome/fonts', '.')
FileUtils.cp_r('bower_components/font-awesome/scss/.', fa_dir)
system("sass #{fa_dir}/font-awesome.scss > #{sass_dir}/_font-awesome.scss")
FileUtils.rm_r(fa_dir)

# Copy jquery

js_dir = 'js/third-party'
FileUtils.mkdir(js_dir) if !File.exists?(js_dir)
FileUtils.cp('bower_components/jquery/dist/jquery.min.js', js_dir)

