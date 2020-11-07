use strict;
use Cwd;
my $dir = getcwd;

my $MAKER_BIN_DIR = "~/bin/maker/bin";
my $SNAP_BIN_DIR = "~/bin/SNAP";

if (!(defined($ARGV[0]) && defined($ARGV[1])))
{
	print "Usage: make_snap_hmm.pl (gff file) (target snap dir)\n";
	exit;
}

my $GFF = $ARGV[0];
my $TARGET_SNAP = $ARGV[1];

if (-d $TARGET_SNAP || -e $TARGET_SNAP)
{
	print "target snap dir [$TARGET_SNAP] already exists. Abort.\n";
#	exit;
}
if (!(-e $GFF))
{
	print "Cannot find file $GFF. Abort.\n";
	exit;
}

my $line;
my @arr;
my $cmd;
my %tmphash;
my $i;
my $j;

#ZFF
$cmd = "mkdir $TARGET_SNAP";
system($cmd);
chdir("$dir/$TARGET_SNAP");

$cmd = "$MAKER_BIN_DIR/maker2zff $dir/$GFF";
system($cmd);

#SNAP
$cmd = "cp genome.ann genome.ann.bak";
system($cmd);
$cmd = "$SNAP_BIN_DIR/fathom genome.ann genome.dna -validate > snap_validate_output.txt";
system($cmd);
open(FILE, "<snap_validate_output.txt");
while(defined($line = <FILE>))
{
	if (index($line, "error") != -1 && $line =~ /: (MODEL[0-9]+) /)
	{
		$tmphash{$1} = 0;
	}
}
close(FILE);

open(FILE, "<genome.ann");
open(OUT, ">genome.ann2");
while(defined($line = <FILE>))
{
	@arr = split(/[ \t]+/, $line);
	chomp($arr[3]);
	if (!(exists $tmphash{$arr[3]}))
	{
		print OUT $line;
	}
}
close(FILE);
close(OUT);

$cmd = "$SNAP_BIN_DIR/fathom genome.ann2 genome.dna -validate > snap_validate_output.txt 2>log";
system($cmd);

open(FILE, "<log");
while(defined($line = <FILE>))
{
	if ($line =~ /([0-9]+) errors/)
	{
		$i = $1;
	}
}
close(FILE);

if ($i != 0)
{
	print "Still $i errors remain after pruning erroneous genome.ann MODELs. Stop and check.\n";
	exit;
}

$cmd = "$SNAP_BIN_DIR/fathom genome.ann2 genome.dna -categorize 1000";
system($cmd);
$cmd = "$SNAP_BIN_DIR/fathom uni.ann uni.dna -export 1000 -plus";
system($cmd);
$cmd = "$SNAP_BIN_DIR/forge export.ann export.dna";
system($cmd);
$cmd = "perl $SNAP_BIN_DIR/hmm-assembler.pl $TARGET_SNAP . > $TARGET_SNAP.hmm";
system($cmd);

chdir($dir);
print "Done preparing $TARGET_SNAP/$TARGET_SNAP.hmm file.\n";



