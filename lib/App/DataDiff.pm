package App::DataDiff;

# Created on: 2020-01-10 09:06:52
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use Scalar::Util;
use List::Util;
use List::MoreUtils qw/zip uniq/;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Path::Tiny;
use YAML::XS qw/LoadFile Load/;
use JSON::XS qw/decode_json encode_json/;

our $VERSION = version->new('0.0.1');

has files => (
    is  => 'rw',
);
has data => (
    is    => 'rw',
    builder => '_data',
    lazy    => 1,
);

sub diff {
    my ($self) = @_;

    return $self->diff_data(zip @{ $self->files }, @{ $self->data });
}

sub diff_data {
    my ($self, $path1, $data1, $path2, $data2) = @_;

    if ( defined $data1 && ! defined $data2 ) {
        $self->difference("missing", $path2);
        return 1;
    }
    elsif ( ! defined $data1 && defined $data2 ) {
        $self->difference("missing", $path1);
        return 1;
    }
    elsif ( ref $data1 ne ref $data2 ) {
        $self->difference("types", $path1, $path2);
        return 1;
    }
    my $diff = 0;

    if ( ref $data1 eq 'HASH' ) {
        my @keys = uniq sort +(keys %$data1), (keys %$data2);
        for my $key (@keys) {
            my $diff_val = $self->diff_data("$path1\{$key}", $data1->{$key}, "$path2\{$key}", $data2->{$key});
            $diff ||= $diff_val;
        }
    }
    elsif ( ref $data1 eq 'ARRAY' ) {
        my $max = @$data1 > @$data2 ? @$data1 : @$data2;
        for my $i (0 .. $max - 1) {
            my $diff_val = $self->diff_data("$path1\[$i]", $data1->[$i], "$path2\[$i]", $data2->[$i]);
            $diff ||= $diff_val;
        }
    }
    elsif ( $data1 ne $data2 ) {
        my $diff_val = $self->difference("value", $path1, $path2, $data1, $data2);
        $diff ||= $diff_val;
    }

    return $diff;
}

sub difference {
    my ($self, $type, $path1, $path2, $data1, $data2) = @_;

    my $len1 = length $path1;
    my $len2 = length $path2 || 0;
    my $len = $len1 > $len2 ? $len1 : $len2;
    if ( @_ > 4 ) {
        printf "%-8s %-${len}s %s\n", $type, $path1, encode_json($data1);
        printf "%-8s %-${len}s %s\n", ' ', $path2, encode_json($data2);
    }
    else {
        printf "%-8s %-${len}s\n", $type, $path1;
        printf "%-8s %-${len}s\n", ' ', $path2 if $path2
    }
}

sub _data {
    my ($self) = @_;
    my @data;

    for my $file (@{ $self->files }) {
        if ( -f $file ) {
            if ( $file =~ /[.]ya?ml$/xms ) {
                push @data, LoadFile($file);
            }
            else {
                push @data, decode_json(scalar path($file)->slurp);
            }
        }
        elsif ( $file =~ /^git:/ ) {
            $file =~ s/^git://;
            my $content = `git show $file`;
            if ( $content =~ /\A---$/xms ) {
                push @data, Load($content);
            }
            else {
                push @data, decode_json($content);
            }
        }
    }

    return \@data;
}


1;

__END__

=head1 NAME

App::DataDiff - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to App::DataDiff version 0.0.1


=head1 SYNOPSIS

   use App::DataDiff;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: App::DataDiff -

Description:

=cut


=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2020 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
