#!/usr/bin/perl
my $USAGE = "Usage: $0 [--inifile se2lx.ini] [--section se2lx_ls] [--debug] [infile.sfm]";
# Reads from an input SFM file (SDTIN if not specified on the command line)
# Outputs to STDOUT
# Removes subentry fields from an SFM Lexical file and promotes
# them to \lx entries.
# Applies to all subentry fields.  Doesn't differentiate whether it
# is under a sense or an entry.  Assumes all are under senses.
# If a subentry comes at the end of an entry, this script will
# treat it as a subentry of the final sense.
#
# Adds \mn markers that refer to the original head and sense.
# Also adds the magic field that is needed for the hack program
#
# Before running, use something like add_hm.pl to
# make sure the homograph numbers are complete, and use
# other tools to make sure all the senses are numbered uniquely.
# [I think we need \hm 1 on entries that have only
# one homograph--is that correct?
# Or add_hm.pl needs to take subentry markers into account.]
# WLP If we have \hm 1 promoted enries will have \mn with a 1 appended.
# 		That would be wrong for entries with only 1 homograph (I think)
#
# And then be sure to run add_hm.pl at the end, to add homograph
# numbers to any newly promoted entries that match existing
# entries. [If single entries had \hm 1, then hopefully the
# subentries will have \hm numbers greater than the main entry.
# The subentries will be in the file before the main entry.]
# WLP This routine won't (and shouldn't ) check whether the newly promoted entry
#		is a  homograph of another entry
#
#     Run it like (scriptname may vary):
#        perl -f se2lx.pl [--inifile filename.ini] [--section name] [--debug] [infile.sfm] > promoted.sfm
#     Options (which can be abbreviated) mean:
#        --inifile: fcontrol file (details below) default
#        --section: section of the inifile to use
#        --debug: print debugging information on STDERR
#        infile.sfm: SFM Lexical file to be processed, if missing read from STDIN
#        promoted.sfm: output file with promoted entries, if not redirected as shown, output to STDOUT
#     Because the script reads STDIN and writes to STDOUT, you can pipe multiple runs like this:
#     cat nopromo.sfm | perl -f se2lx.pl --section se2lx_ls | perl -f se2lx.pl --section se2lx_ld >ls-ld-promo.sfm
#
# Promoted subentries are written out in the order they occur following the main entry 

=pod
Here is a sample INI file with a couple of sections

# A sample ini file for the se2lx.pl script
[se2lx_lc]
SubentryMkr=lc
ParentsSenseMkr=ms
SpecialTag=_COMPOUND_
EndMkrs=lx, lc, ld,li, , ls,ms,sc,rx,rtx,,,dt
# If you want the subentry to inherit the date include the next line
DateMkr=dt

[se2lx_ls]
SubentryMkr=ls
ParentsSenseMkr=ms
SpecialTag=_SAYING_
EndMkrs=lx,ls,lc,ld,li,ms,ps,sc,rx,rtx,dt

[endofinifile]
=cut
#Version History
# 22 Mar 2018	v5	bb	Edited to fit other database facts:
#						\dt doesn't end record; don't update date.
#						different field order.
# 10 Dec 2018	v6	bb	Clean up some of the comments
#						Work on it with Wes
# 10 Dec 2018	v7	BB	Add more markers as end markers
# 29 Jan 2019 	v8 WLP Extensive re-write
#						move opl/de-opl into program
#							slurp file into an arrray
#						add ini control file with command line options to choose the section
#						Mandatory ini items with examples:
#							[se2lx_ls]
#							SubentryMkr=ls
#							ParentsSenseMkr=ms
#							SpecialTag=_SAYING_
#							EndMkrs=lx,ls,lc,ld,li,ms,ps,sc,rx,rtx
#						Optional ini items:
#							DateMkr=dt
#
#						Clean up EndMkrs
#						set default ini name to match the script name
#						simplify & capture nondigit regex for ParentsSenseMkr error check

# Bugs/Enhancements:
# 		Need to check for null strings on INI file variables
# 		Could add a list of end markers that are included in the subentry (Larry's idea)
#			Probably append these markers to the EndMkrs list
#			If $afterstuff starts with an include marker, delete from $afterstuff and
#			append to $subentry

use 5.016;
use utf8;
use open qw/:std :utf8/;

use strict;
use warnings;
use English;
use Data::Dumper qw(Dumper);

use File::Basename;
my $scriptname = fileparse($0, qr/\.[^.]*/); # script name without the .pl
use Getopt::Long;
GetOptions (
	'inifile:s'   => \(my $inifilename = "$scriptname.ini"), # ini filename
	'section:s'   => \(my $inisection = "se2lx_se"), # section of ini file to use
	'debug'       => \my $debug,
	) or die $USAGE;

# Customize these values for the specific data.

use Config::Tiny;
my $config = Config::Tiny->read($inifilename, 'crlf');
die "Quitting: couldn't find the INI file $inifilename\n$USAGE\n" if !$config;
die "Quitting: couldn't find the [$inisection] section in  the INI file $inifilename\n$USAGE\n" if !exists $config->{"$inisection"};
# Subentry marker
# If there is more than one Complex Form Type, need to
# repeat this, and the code below that applies it.
# The marker doesn't include the backslash or following space
my $SubentryMkr = $config->{"$inisection"}->{SubentryMkr};

# date marker if you should process a date field
my $DateMkr = "";
if ($config->{"$inisection"}->{DateMkr}) {
	$DateMkr = $config->{"$inisection"}->{DateMkr}
	};
# Special marker for the .fwdata script,
# to indicate the Complex Form Type
# It needs to have special characters so that it won't match the tag text of a model entry
#	e.g. the special tag for idiom might be _Idiom_ (with underscores)
#        the model text in the FLEx database record might be "Model Idiom"
#        "Model Idiom" doesn't contain "_Idiom_" as a substring and vice versa
#        this prevents a search for one buggily finding the other
my $SpecialTag = $config->{"$inisection"}->{SpecialTag};
# clean up endmarkers
$config->{"$inisection"}->{EndMkrs} =~ s/ //g; # no spaces in the end marker list
$config->{"$inisection"}->{EndMkrs} =~ s/,+/,/g; # no empty markers
$config->{"$inisection"}->{EndMkrs} =~ s/,$//; # no empty markers (cont.)
$config->{"$inisection"}->{EndMkrs} =~ s/,/\|/g; # alternatives  are '|' in Regexes
my $EndMkrRE = '(?<=#)\\\\(' . $config->{"$inisection"}->{EndMkrs} . ')[# ]';
# need 4 \\\\ because variable will be evaluated
# EndMkrs=lx,ls,lc,ld,li,ms,ps,sc,rx,rtx -> '\\\\(lx|ls|lc|ld|li|ms|ps|sc|rx|rtx)[# ]'
my $ParentsSenseMkr = $config->{"$inisection"}->{ParentsSenseMkr};

# generate array of with one SFM record per line (opl)
my @opledfile_in;
my $line = ""; # accumulated SFM record
while (<>) {
	s/\R//g; # chomp that doesn't care about Linux & Windows
	#perhaps s/\R*$//; if we want to leave in \r characters in the middle of a line
	s/#/\_\_hash\_\_/g;
	$_ .= "#";
	if (/^\\lx /) {
		$line =~ s/#$/\n/;
		push @opledfile_in, $line;
		$line = $_;
		}
	else { $line .= $_ }
	}
push @opledfile_in, $line;

#=pod
say STDERR "inisection:$inisection" if $debug;
say STDERR "inifile:$inifilename" if $debug;
say STDERR "EndMkrRE :$EndMkrRE" if $debug;
say STDERR "SubentryMkr:$SubentryMkr" if $debug;
say STDERR "ParentsSenseMkr:$ParentsSenseMkr" if $debug;
say STDERR "DateMkr:$DateMkr" if $debug;
say STDERR "SpecialTag:$SpecialTag" if $debug;
if ($debug) { say STDERR "config:", Dumper($config) };
# if ($debug) {for (@opledfile_in) {say STDERR} };
#=cut
for my $oplline (@opledfile_in) {
	# Pattern that matches the beginning of what immediately follows
	# the subentry.  (This tells us we've started something new, and
	# this will not be included in the subentry.)

	my @opled_subentries =(); # cumulation of subentries in the current record
	my $lxfield =""; # key of master record -- no #
	my $subentry = ""; # text of subentry record -- trailing #
	my $hmno = ""; # text of homograph number if any -- no #
	my $beforestuff = "";	#preceding subentry record i.e.: \lx ... <char before \se> -- trailing #
	my $afterstuff = "";	# master record text following subentry i.e. <field following subentry>...\dt field  -- trailing #
	my $snno = ""; # text of sense number if any -- no #
	my @snfields = "";


	if ($oplline =~ /\\lx ([^#]*?)#/) {
		$lxfield = $1;
		print STDERR "\nlx=[$lxfield]\n" if $debug;
		}

	#$hmno="";
	if ($oplline =~ /\\hm ([^#]*?)#/) {
		$hmno= $1;
		print STDERR "hm=[$hmno]\n" if $debug;
		}

	# Process date markers if the ini file specified it.
	my $dt = "";
	if ($DateMkr && $oplline =~ /\\$DateMkr ([^#]*?)#/) {
		$dt = $1;
		print STDERR "  $DateMkr=[$dt]\n" if $debug;
		}

	# Do some error checking on the Sense field on the current record
	# Check for empty sense fields
	if ($oplline =~ /\\$ParentsSenseMkr#/) {
		print STDERR "Empty \\$ParentsSenseMkr field(s) found in \\lx $lxfield$hmno\nThe script will continue, but you may get better results if you first ensure that all sense fields are populated and unique.\n";
		}

	# Check for non-digits in sense fields
	if ($oplline =~ /(\\$ParentsSenseMkr [0-9\.]*[^0-9\.#][^#]*)#/) {
		print STDERR "Non-digit content \\$ParentsSenseMkr field(s) \"$1\" found in \\lx $lxfield$hmno\nThe script will continue, but you may get better results if you first ensure that all sense fields consist only of digits and full stops.\n";
		}

	# Match from $SubentryMkr up until whatever comes immediately after the subentry.
	# The look-behind (?<=#)  only matches markers immediately preceded by #
	# i.e. at the beginning of the line. Won't match in the middle, as in a comment.
	while (($oplline =~ /(?<=#)\\$SubentryMkr .*?(?=($EndMkrRE))/)
		|| ($oplline =~ /(?<=#)\\$SubentryMkr .*/))  {
		# Debug output
		print STDERR "\n" if $debug;
		# Parse the string into: what's before the subentry, the subentry,
		# and what is after it.  Only the subentry part will be processed
		# in this loop.
		$beforestuff = $PREMATCH;
		$afterstuff = $POSTMATCH;
		$subentry = $MATCH;

		## Collect all the preceding sense numbers into an array.
		## Each will include the space before it,
		## and empty ones will be the null string.
		## Still need to handle \snSE type markers.
		## WLP: make it an array like the endmarkers?
		## WLP: needs a (?<=#) look-behind like the $SubentryMkr
		@snfields = $beforestuff =~ /(?<=#)\\$ParentsSenseMkr ([^#]*?)#/g;

		# Set this to the last element of the array,
		# that is, the sense number of the last sense
		# before the matched subentry.
		# It includes the preceding space, so we don't need it later.
		# And if it is empty, then it will be the null string.
		$snno = $snfields[-1];
		print STDERR " $lxfield: sn=[$snno]\n" if $debug;
		$snno = "" if ! defined $snno;

		# We want to add a special field with unique text
		# for the post-processing step.  For example:
		# \spec _DERIV_
		# Check for pre-existing ?

		# Finally, make the substitution that converts the
		# subentry to an entry.
		my $mnfield = "$lxfield$hmno";
		$mnfield .= " $snno" if $snno;

		if ($subentry =~ m/\\$SubentryMkr [^#]*#\\hm/) {
			$subentry =~ s/\\$SubentryMkr ([^#]*)(#\\hm [^#]*)*#/\\lx $1$2#\\mn $mnfield#\\spec $SpecialTag#/;
		}
		else {
			$subentry =~ s/\\$SubentryMkr ([^#]*?)#/\\lx $1#\\mn $mnfield#\\spec $SpecialTag#/;
			# if the subentry had a trailing homograph number, make it a homograph field
			$subentry =~s/(\\lx [^#]*?)(\d+)#/$1#\\hm $2#/;
		}

		if ($DateMkr && $dt) { $subentry .= "\\$DateMkr $dt#" };

		# Add the promoted record into the accumulated array
		# Assumes we are inheriting the date from the parent entry,
		# or printing an empty date field.
		push @opled_subentries, "$subentry#" ;

		# Delete subentry from master record.
		# (This deletion allows the test condition in
		# the while loop to change.  The loop continues until
		# there are no more subentries to delete from the
		# main record.)
		$oplline =$beforestuff . $afterstuff;
		}

	for ($oplline, @opled_subentries) {
		s/#/\n/g;
		s/\_\_hash\_\_/#/g;
		print;
		say STDERR "oplline:", Dumper($oplline) if $debug;
		say STDERR "opled_subentries:", Dumper(@opled_subentries) if $debug;
		}
	@opled_subentries = ();
	}
