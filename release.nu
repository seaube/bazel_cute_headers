source setup.nu

let release_name = "bazel-cute-headers-" + (date now | format date "%Y-%m-%d");
let release_dist_dir = $root_dir + '/release';

rm -rf $release_dist_dir;
mkdir $release_dist_dir;

def make_release_archive [module_name, module_config] {
  let module_header = $module_name + '.h';
  let module_dir = $root_dir + '/' + $module_name;
  let version = $module_config | get version;
  let output_archive = $root_dir + '/release/bzlmod_' + $module_name + '_' + $version + ".tar.gz";

  cd $module_dir; 
  echo $"Creating ($output_archive | path relative-to $root_dir) ...";
  git archive HEAD . --add-file $module_header -o $output_archive;
}

$versions | columns | each {|col| make_release_archive $col ($versions | get $col) }

echo $"Releasing ($release_name) ...";

gh release create $release_name --generate-notes ...(ls ($release_dist_dir + '/*.tar.gz') | each {|i| $i.name});

