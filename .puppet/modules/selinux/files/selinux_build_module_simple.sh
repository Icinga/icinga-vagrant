#!/bin/sh
module_name="$1"
module_dir="$2"

set -e

cd $module_dir
test -d tmp || mkdir tmp

checkmodule -M -m -o tmp/${module_name}.mod ${module_name}.te
package_args="-o ${module_name}.pp -m tmp/${module_name}.mod"
if [ -s "${module_name}.fc" ]; then
    package_args="${package_args} --fc ${module_name}.fc"
fi

semodule_package ${package_args}
