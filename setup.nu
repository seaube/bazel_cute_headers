const repo = "RandyGaul/cute_headers";
let source_prefix = $"https://github.com/($repo)/blob/";
let raw_source_prefix = $"https://raw.githubusercontent.com/($repo)/";
let root_dir = $env.FILE_PWD;
let versions = open versions.toml;

def setup_module [module_name, module_config] {
  let module_header = $module_name + '.h';
  let module_dir = $root_dir + '/' + $module_name;
  let version = $module_config | get version;
  let commit = $module_config | get commit;
  let compatibility_level = $version | split row '.' | get 0;

  print $"Setting up ($module_name)";

  cd $module_dir;
  buildozer $'set version ($version)' $'set compatibility_level ($compatibility_level)' //MODULE.bazel:%module
  curl -sL -o $module_header ($raw_source_prefix + $commit + '/' + $module_header);
}

def module_readme_table_line [module_name, module_config] {
  let module_header = $module_name + '.h';
  let version = $module_config | get version;
  let commit = $module_config | get commit;
  $"| ($module_name) | ($version) | [($commit)]\(($source_prefix)($commit)/($module_header)\) |"
}

def update_versions_readme_table [] {
  let readme_file_path = $root_dir + '/README.md';
  let readme_contents = open $readme_file_path | lines;
  let begin_versions_table_str = '<!-- BEGIN VERSIONS TABLE -->';
  let end_versions_table_str = '<!-- END VERSIONS TABLE -->';

  let readme_contents_before = $readme_contents | split list $begin_versions_table_str | get 0 | append $begin_versions_table_str;
  let readme_contents_after = $readme_contents | split list $end_versions_table_str | get 1 | prepend $end_versions_table_str;
  let version_table_rows = $versions | columns | each {|col| module_readme_table_line $col ($versions | get $col) };

  ($readme_contents_before ++ $version_table_rows ++ $readme_contents_after) | save $readme_file_path -f --raw;
}

$versions | columns | each {|col| setup_module $col ($versions | get $col) }
update_versions_readme_table

