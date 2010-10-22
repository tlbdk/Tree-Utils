use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'Tree::Util',
    license            => 'perl',
    dist_author        => 'Troels Liebe Bentsen <troels@it-kartellet.dk>',
    dist_version_from  => 'lib/Tree/Util.pm',
    create_readme      => 1,
    create_makefile_pl => 'passthrough',
    requires => { 
        'perl'             => '>= 5.8.0',
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup => [ 
        'Tree-Util-*',
        'Makefile',
        'blib',
    ],
);

$builder->create_build_script();
