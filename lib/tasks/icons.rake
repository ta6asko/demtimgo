# frozen_string_literal: true

require 'rake'

namespace :icons do
  desc 'update the icon font files from a newly downloaded zip file'
  task :update, [:zipfile] => [:environment] do |_t, args|
    # Set absolute zipfile path in ~/Downloads
    zipfile = File.join(ENV['HOME'], 'Downloads', args[:zipfile].shellescape)

    # Set some dir vars
    tmpdir = Rails.root.join('tmp', 'iconfont')
    vendor_css_dir = Rails.root.join('vendor', 'assets', 'stylesheets', 'spree', 'frontend', 'styleguide')
    app_fonts_dir = Rails.root.join('app', 'assets', 'fonts')

    # Create the tmp folder for extracted zip
    system "mkdir #{tmpdir}" unless File.directory? tmpdir

    # Unzip that motherfucker
    system "unzip -u #{zipfile} -d #{tmpdir}"

    # Copy the font files
    Dir.glob(File.join(tmpdir, 'fonts', '*')) do |file|
      puts "Copying #{file} to #{app_fonts_dir}"
      system "cp #{file} #{app_fonts_dir}"
    end

    # Copy the stylesheet
    puts 'Copying the stylesheet'
    stylesheet = File.join(vendor_css_dir, '_icons.scss')
    system "cp #{File.join(tmpdir, 'style.css')} #{stylesheet}"

    # Replace the font urls in the stylesheet
    puts 'Updating font URLs in stylesheet'
    stylesheet_content = File.read(stylesheet)
    stylesheet_content.gsub!("url('fonts/", "font-url('")
    File.open(stylesheet, 'w') do |file|
      file.write(stylesheet_content)
    end
  ensure
    puts 'Deleting tmp folder'

    system "rm -rf #{tmpdir}" if File.directory? tmpdir
  end
end
