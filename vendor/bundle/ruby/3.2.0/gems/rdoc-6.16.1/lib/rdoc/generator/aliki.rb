# frozen_string_literal: true

##
# Aliki theme for RDoc documentation
#
# Author: Stan Lo
#

class RDoc::Generator::Aliki < RDoc::Generator::Darkfish
  RDoc::RDoc.add_generator self

  def initialize(store, options)
    super
    aliki_template_dir = File.expand_path(File.join(__dir__, 'template', 'aliki'))
    @template_dir = Pathname.new(aliki_template_dir)
  end

  ##
  # Copy only the static assets required by the Aliki theme. Unlike Darkfish we
  # don't ship embedded fonts or image sprites, so limit the asset list to keep
  # generated documentation lightweight.

  def write_style_sheet
    debug_msg "Copying Aliki static files"
    options = { verbose: $DEBUG_RDOC, noop: @dry_run }

    install_rdoc_static_file @template_dir + 'css/rdoc.css', "./css/rdoc.css", options

    unless @options.template_stylesheets.empty?
      FileUtils.cp @options.template_stylesheets, '.', **options
    end

    Dir[(@template_dir + 'js/**/*').to_s].each do |path|
      next if File.directory?(path)
      next if File.basename(path).start_with?('.')

      dst = Pathname.new(path).relative_path_from(@template_dir)

      install_rdoc_static_file @template_dir + path, dst, options
    end
  end
end
