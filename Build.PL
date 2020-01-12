use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'App::DataDiff',
	license           => 'perl',
	dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from => 'lib/App/DataDiff.pm',
	requires          => {
		'perl'             => 5.008,
	},
	build_requires => {
		'Test::More'     => 0,
		'Test::Warnings' => 0,
	},
	add_to_cleanup     => [ 'App-DataDiff-*' ],
	create_license     => 1,
	meta_merge => {
		resources => {
			repository => 'git://github.com/ivanwills/App-DataDiff.git',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App::DataDiff',
		},
	},
);

$builder->create_build_script();
