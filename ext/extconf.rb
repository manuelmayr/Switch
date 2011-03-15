#!/usr/bin/env ruby

require "mkmf"

PROJECT = "pathfinder"

PATHFINDER_INCLUDE = ENV['PATHFINDER_INCLUDE'] or
                     Dir['/usr/*/pathfinder/include'].last
PATHFINDER_LIB = ENV['PATHFINDER_LIB'] or
                 Dir['/usr/*/pathfinder/lib'].last

def crash(str)
  printf("extconf failure:\n%s\n", str)
  exit 1
end

# enable flags
# --with-pathfinder-dir,
# --with-pathfinder-lib,
# --with-pathfinder-include
dir_config(PROJECT, PATHFINDER_INCLUDE, PATHFINDER_LIB)

# checking for libraries, headers
# and their corresponding entry points
unless ((have_library('pf_ferry','PFcompile_ferry') or
         find_library('pf_ferry','PFcompile_ferry', PATHFINDER_LIB)) and
        (have_library('pf_ferry','PFcompile_ferry_opt') or
         find_library('pf_ferry','PFcompile_ferry_opt', PATHFINDER_LIB)) and
        (have_header('pf_ferry.h') or
        find_header('pf_ferry.h', PATHFINDER_INCLUDE)))
  crash(<<EOF)
Sorry, I'm unable to locate Pathfinder libraries.

Follow the steps below and retry

Step1: - Install Pathfinder

Step2: - Set the environment variables PATHFINDER_INCLUDE and PATHFINDER_LIB as below

           (assuming bash shell)

           export PATHFINDER_INCLUDE=PFHOME/include/
           export PATHFINDER_LIB=PFHOME/lib/

Step3: - Retry installing the gem
EOF
end

have_header("signal.h")
create_header();
$CFLAGS << ' -Wall'
create_makefile(PROJECT)
