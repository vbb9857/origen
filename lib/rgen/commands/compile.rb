require 'optparse'

options = {}

# App options are options that the application can supply to extend this command
app_options = @application_options || []
opt_parser = OptionParser.new do |opts|
  opts.banner = <<-EOT
Compile an ERB template file, list of files or a directory.
If a directory is referenced the entire sub-directory structure will be copied to the output directory, compiling any ERB
templates it finds in the process and copying any standard files accross without modification.

ERB is a templating system from Ruby that allows you to embed snippets of Ruby code in any ASCII file to create dynamic
content. Within the context of the rgen generator this means that you can include Ruby snippets that reference the target
objects to create dynamic test program sheets, C files, VB files, documentation, etc.

To create an ERB template start with a base ASCII file and append .erb to the end of the file name, upon compilation the
.erb extension will be removed.

There is not much to the syntax, this snippet covers just about everything you need to know:
   %       - A full line of Ruby is prefixed with %, this is removed by compilation
   %#      - A full line Ruby comment, this is removed by compilation
   <%#  %> - An embedded Ruby comment, this is removed by compilation
   <%   %> - An embedded Ruby snippet, this is removed by compilation
   <%=  %> - An embedded Ruby snippet that generates content, the result is output to the compiled file

Full details of ERB syntax can be found here:
   http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html

Usage: rgen compile [space separated files, lists or directories] [options]
  EOT
  opts.on('-e', '--environment NAME', String, 'Override the default environment, NAME can be a full path or a fragment of an environment file name') { |e| options[:environment] = e }
  opts.on('-t', '--target NAME', String, 'Override the default target, NAME can be a full path or a fragment of a target file name') { |t| options[:target] = t }
  opts.on('-pl', '--plugin PLUGIN_NAME', String, 'Set current plugin') { |pl_n|  options[:current_plugin] = pl_n }
  opts.on('-l', '--lsf [ACTION]', [:clear, :add], "Submit jobs to the LSF, optionally specify whether to 'clear' or 'add' to existing jobs") { |a| options[:lsf] = true; options[:lsf_action] = a }
  opts.on('-w', '--wait', 'Wait for LSF processing to complete') { options[:wait_for_lsf_completion] = true }
  opts.on('-c', '--continue', 'Continue on error (to the next file)') { options[:continue] = true }
  opts.on('-d', '--debugger', 'Enable the debugger') {  options[:debugger] = true }
  opts.on('-m', '--mode MODE', RGen::Mode::MODES, 'Force the RGen operating mode:', '  ' + RGen::Mode::MODES.join(', ')) { |_m| }
  opts.on('-f', '--file FILE', String, 'Override the default log file') { |o| options[:log_file] = o }
  opts.on('-o', '--output DIR', String, 'Override the default output directory') { |o| options[:output] = o }
  opts.on('-n', '--name NAME', String, 'Override the default output file name') { |o| options[:output_file_name] = o }
  opts.on('-r', '--reference DIR', String, 'Override the default reference directory') { |o| options[:reference] = o }
  opts.on('-z', '--zip', 'Gzip all output files (diff checking will be skipped)') { |o| options[:zip] = o }
  app_options.each do |app_option|
    opts.on(*app_option) {}
  end
  opts.separator ''
  opts.on('-h', '--help', 'Show this message') { puts opts; exit 0 }
end

opt_parser.parse! ARGV
options[:patterns] = ARGV
options[:compile] = true  # To let the generator know a compile job has been requested

RGen.load_application
RGen.current_plugin.temporary = options[:current_plugin] if options[:current_plugin]
RGen.environment.temporary = options[:environment] if options[:environment]
RGen.target.temporary = options[:target] if options[:target]
RGen.app.load_target!
RGen.app.runner.generate(options)
RGen.lsf.wait_for_completion if options[:wait_for_lsf_completion]