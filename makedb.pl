#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

#use Data::Dumper;
my %deps;
my %pkgs;
my %repofiles;

sub repofiles {
	my ($base, $pkg, $l, $version) = @_;
	$repofiles{$base}{"$pkg-$version-x86_64.pkg.tar"}++;
}

sub urls($$$) {
	#and then Arch started to use .zst compression
	$pkgs{"https://archive.archlinux.org/packages/$2/$1/$1-$3-x86_64.pkg.tar.zst"}++;
	$pkgs{"https://archive.archlinux.org/packages/$2/$1/$1-$3-x86_64.pkg.tar.zst.sig"}++;
	#but not for all pacakges, so .xz is still a thing
	$pkgs{"https://archive.archlinux.org/packages/$2/$1/$1-$3-x86_64.pkg.tar.xz"}++;
	$pkgs{"https://archive.archlinux.org/packages/$2/$1/$1-$3-x86_64.pkg.tar.xz.sig"}++;
}

while(<>) {

	if (m/^%BASE%/) {
		my $base=<>;
		chomp $base;

		pkg: while(<>) {
			if (m/^%DEPENDS/) {
				while(<>) {
					chomp;
					last if $_ eq "";
					if (m/linux.*=/) {
						$deps{$base}{$_}++;
					}
					if (m/((l)inux.*)=(.*)/) {
						urls($1,$2,$3);
						repofiles($base,$1,$2,$3);
					}
				}
			}
			if (m/^%MAKEDEPENDS/) {
				while(<>) {
					chomp;
					last pkg if $_ eq "";
					if (m/linux.*=/) {
						$deps{$base}{$_}++;
					}
					if (m/((l)inux.*)=(.*)/) {
						urls($1,$2,$3);
						repofiles($base,$1,$2,$3);
					}
				}
			}
#			last;
		}
	}
}

open (URLS, '>urls');
foreach my $pkg (sort keys %pkgs) {
	printf URLS "$pkg\n";
}
close URLS;

open (SH, '>repo-add.sh');
printf SH "#!/bin/sh\n";
foreach my $pkg (sort keys %repofiles) {
	printf SH "mkdir -p -- 'out/$pkg' || true\n";
	for my $file (sort keys %{$repofiles{$pkg}}) {
		#these have to be put two different files and repo-add will fail if it can't find one
		#of course '%s'.* will not work either as it can't process/ignore .sig files
		printf SH "repo-add --nocolor 'out/$pkg/$pkg.db.tar.xz' '%s.xz' || true\n", $file;
		printf SH "repo-add --nocolor 'out/$pkg/$pkg.db.tar.xz' '%s.zst' || true\n", $file;
	}
}
close SH;

#print Dumper \%deps;
#print Dumper \%pkgs;
#print Dumper \%repofiles;
