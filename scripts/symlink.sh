#!/bin/bash
# Usage: sh simlink.sh
# Adds symlinks to each project's environment, for all the modules and project configs.
# Needs to be run from the /terraform subfolder.
# Expects the following repository folder structure:
#
# /     # repo root
# /terraform
# /terraform/modules  # modules shared across all projects
# /terraform/modules/somesharedprojectmodule
# /terraform/modules/somesharedprojectmodule/main.tf
# /terraform/projects
# /terraform/projects/yourproject    # your project's main configs
# /terraform/projects/yourproject/main.tf
# /terraform/projects/yourproject/environments
# /terraform/projects/yourproject/environments/dev    # configs specific to this environment
# /terraform/projects/yourproject/environments/dev/terraform.tfvars
# /terraform/projects/yourproject/modules    # modules specific to this project
# /terraform/projects/yourproject/modules/somelocalmodule
# /terraform/projects/yourproject/modules/somelocalmodule/main.tf

echo "Starting simlink job"
shopt -s nullglob
project_modules=`cd modules 2>/dev/null && ls -d *`
projects=`cd projects && ls -d *`
root=$PWD
echo project_modules: $project_modules
echo projects: $projects

for project in $projects
do
  echo $project
  project_root="$PWD"
  cd "projects/$project"
  environments=`cd environments && ls -d *`
  local_modules=`cd modules 2>/dev/null && ls -d *`

  for env in $environments
  do
    echo "  Environment: $env"
    cd "environments/$env"
    project_files=`ls ../../*.tf*`
    rm .gitignore

    # Link project configs to this environment and add to gitignore
    for project_file in ${project_files[*]};
    do
      echo "    project file:$project_file"
      ln -sfn $project_file .
      echo "$project_file" | sed 's/..\///g' >> .gitignore
    done

    # Link project models to this environment and add to gitignore
    for module in ${project_modules[*]};
    do
      if [ "$module" != "." ]; then
        echo "    project module:$module"
        ln -sfn ../../../../modules/$module .
        echo "$module"  >> .gitignore
      fi
    done

    # Link local modules to this environment and add to gitignore
    for module in ${local_modules[*]};
    do
      if [ "$module" != "." ]; then
        echo "    local module:$module"
        ln -sfn ../../modules/$module .
        echo "$module" | sed 's/..\///g' >> .gitignore
      fi
    done

    cd ../../
  done
  cd "$project_root"
done
cd "$root"
echo "Finished simlink job!"