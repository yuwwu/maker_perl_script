use strict;
use Cwd;
my $dir = getcwd;

my $SNAP_BIN_DIR = "~/bin/SNAP";
my $MAKER_BIN_DIR = "~/bin/maker/bin";
my $AUGUSTUS_BIN_DIR = "~/bin/Augustus/bin";
my $AUGUSTUS_SCRIPTS_DIR = "~/bin/Augustus/scripts";

if (!(defined($ARGV[0]) && defined($ARGV[1])))
{
	print "Usage: make_snap_hmm.pl (target snap dir) (species name)\n";
	exit;
}

my $TARGET_SNAP = $ARGV[0];
my $SPECIES_NAME = $ARGV[1];

if (!(-e "$TARGET_SNAP/$TARGET_SNAP.hmm"))
{
	print "Cannot find required files (export.ann and export.dna) in target snap dir $TARGET_SNAP. Abort.\n";
	exit;
}

my $line;
my @arr;
my $cmd;
my %tmphash;
my $i;
my $j;

chdir("$dir/$TARGET_SNAP");

$cmd = "perl $SNAP_BIN_DIR/zff2augustus_gbk.pl > augustus.gbk";
system($cmd);
$cmd = "perl $AUGUSTUS_SCRIPTS_DIR/randomSplit.pl augustus.gbk 100";
system($cmd);
$cmd = "perl $AUGUSTUS_SCRIPTS_DIR/new_species.pl --species=$SPECIES_NAME";
system($cmd);
$cmd = "$AUGUSTUS_BIN_DIR/etraining --species=$SPECIES_NAME augustus.gbk.train";
system($cmd);
$cmd = "$AUGUSTUS_BIN_DIR/augustus --species=$SPECIES_NAME augustus.gbk.test | tee first_training.out";
system($cmd);

# Optimization starts!
$cmd = "$AUGUSTUS_SCRIPTS_DIR/optimize_augustus.pl --species=$SPECIES_NAME augustus.gbk.train";
system($cmd);


