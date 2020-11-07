use strict;
use Cwd;
my $dir = getcwd;

if (!(defined($ARGV[0]) && defined($ARGV[1])))
{
	print "Usage: collect_split_maker.pl (output gff) (output fasta header)\n";
	exit;
}
my $gffout = $ARGV[0];
my $fastaout = $ARGV[1];

if (-e "$gffout")
{
	print "Output GFF file already exists. Rename or delete it before proceeding.\n";
	exit;
}

my $gff3_merge = "~/bin/maker/bin/gff3_merge";
my $fasta_merge = "~/bin/maker/bin/fasta_merge";

if (!(-e "maker_opts.ctl") || !(-e "maker_exe.ctl") || !(-e "maker_bopts.ctl"))
{
	print "Please make sure you are in the correct folder containing maker control files.\n";
	exit;
}

my $parts = 0;

my $line;
my $f;
my @arr;
my $i;
my $j;
my $tmp;
my $tmp2;
my %tmphash;

my $genome;
my $header;

my $seqnum = 0;
my %lenhash;
my %seqhash;
my $totallen = 0;
my $cmd;
my $cutoff;

open(FILE, "<maker_opts.ctl");
while(defined($line = <FILE>))
{
	if ($line =~ /^genome=/)
	{
		$genome = substr($line, 7);
		if (($i = index($genome, " ")) != -1)
		{
			$genome = substr($genome, 0, $i);
		}
		if (($i = index($genome, "#")) != -1)
		{
			$genome = substr($genome, 0, $i);
		}
	}
}
close(FILE);

$header = substr($genome, 0, rindex($genome, "."));

opendir(DIR, ".");
$i = 0;
while($f = readdir(DIR))
{
	if ($f =~ /^maker.tmp([0-9]+)/)
	{
		if ($parts < $1)
		{
			$parts = $1;
		}
		open(FILE, "<$f/maker.err") || die "Cannot open $f/maker.err\n";
		$j = 0;
		while(defined($line = <FILE>))
		{
			if (index($line, "Maker is now finished!!!") != -1)
			{
				$j = 1;
				last;
			}
		}
		if ($j == 0)
		{
			$tmphash{$f} = 0;
		}
	}
}
closedir(DIR);

$j = scalar keys %tmphash;
if ($j > 0)
{
	print "Some maker runs are not finished yet.\n";
	foreach $tmp (sort keys %tmphash)
	{
		print "\t$tmp\n";
	}
	exit;
}

if ($parts == 0)
{
	print "Failed to detect temporary maker directories. Check if this is the correct folder.\n";
	exit;
}

print "Parts = $parts\n";

for ($i = 1; $i <= $parts; $i++)
{
	chdir("maker.tmp$i");
	$cmd = "$gff3_merge -d $header.maker.output/$header\_master_datastore_index.log -o gff3";
	system($cmd);
	$cmd = "$fasta_merge -d $header.maker.output/$header\_master_datastore_index.log -o fasta";
	system($cmd);
	chdir($dir);
}




#collect gff3

open(GFF1, ">tmpgff1");
open(GFF2, ">tmpgff2");
print GFF2 "##FASTA\n";
for ($i = 1; $i <= $parts; $i++)
{
	chdir("maker.tmp$i");
	open(FILE, "<gff3") || die "Cannot open gff file in tmp$i\n";
	$j = 0;
	while(defined($line = <FILE>))
	{
		if ($line =~ /##FASTA/)
		{
			$j = 1;
		}
		else
		{
			if ($j == 0)
			{
				print GFF1 $line;
			}
			elsif ($j == 1)
			{
				print GFF2 $line;
			}
		}
	}
	close(FILE);
	chdir($dir);
}
close(GFF1);
close(GFF2);

$cmd = "cat tmpgff1 tmpgff2 > $gffout";
system($cmd);

unlink("tmpgff1");
unlink("tmpgff2");

# Collect FASTA
open(AUGUSTUS_PROTEIN, ">$fastaout.all.maker.augustus_masked.proteins.fasta");
open(AUGUSTUS_TRANSCRIPT, ">$fastaout.all.maker.augustus_masked.transcripts.fasta");
open(AB_INITIO_PROTEIN, ">$fastaout.all.maker.non_overlapping_ab_initio.proteins.fasta");
open(AB_INITIO_TRANSCRIPT, ">$fastaout.all.maker.non_overlapping_ab_initio.transcripts.fasta");
open(SNAP_PROTEIN, ">$fastaout.all.maker.snap_masked.proteins.fasta");
open(SNAP_TRANSCRIPT, ">$fastaout.all.maker.snap_masked.transcripts.fasta");
open(GENEMARK_PROTEIN, ">$fastaout.all.maker.genemark.proteins.fasta");
open(GENEMARK_TRANSCRIPT, ">$fastaout.all.maker.genemark.transcripts.fasta");
open(ALL_PROTEIN, ">$fastaout.all.maker.proteins.fasta");
open(ALL_TRANSCRIPT, ">$fastaout.all.maker.transcripts.fasta");
open(TRNA_TRANSCRIPT, ">$fastaout.all.maker.trnascan.transcripts.fasta");

for ($i = 1; $i <= $parts; $i++)
{
	chdir("maker.tmp$i");

	open(FILE, "<fasta.all.maker.augustus_masked.proteins.fasta");
	while(defined($line = <FILE>))
	{
		print AUGUSTUS_PROTEIN $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.augustus_masked.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print AUGUSTUS_TRANSCRIPT $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.snap_masked.proteins.fasta");
	while(defined($line = <FILE>))
	{
		print SNAP_PROTEIN $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.snap_masked.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print SNAP_TRANSCRIPT $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.non_overlapping_ab_initio.proteins.fasta");
	while(defined($line = <FILE>))
	{
		print AB_INITIO_PROTEIN $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.non_overlapping_ab_initio.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print AB_INITIO_TRANSCRIPT $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.genemark.proteins.fasta");
	while(defined($line = <FILE>))
	{
		print GENEMARK_PROTEIN $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.genemark.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print GENEMARK_TRANSCRIPT $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.proteins.fasta");
	while(defined($line = <FILE>))
	{
		print ALL_PROTEIN $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print ALL_TRANSCRIPT $line;
	}
	close(FILE);
	open(FILE, "<fasta.all.maker.trnascan.transcripts.fasta");
	while(defined($line = <FILE>))
	{
		print TRNA_TRANSCRIPT $line;
	}
	close(FILE);

	chdir($dir);
}
close(AUGUSTUS_PROTEIN);
close(AUGUSTUS_TRANSCRIPT);
close(SNAP_PROTEIN);
close(SNAP_TRANSCRIPT);
close(AB_INITIO_PROTEIN);
close(AB_INITIO_TRANSCRIPT);
close(GENEMARK_PROTEIN);
close(GENEMARK_TRANSCRIPT);
close(ALL_PROTEIN);
close(ALL_TRANSCRIPT);
close(TRNA_TRANSCRIPT);

if ((-s "$fastaout.all.maker.augustus_masked.proteins.fasta") == 0)
{
	unlink("$fastaout.all.maker.augustus_masked.proteins.fasta");
}
if ((-s "$fastaout.all.maker.augustus_masked.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.augustus_masked.transcripts.fasta");
}
if ((-s "$fastaout.all.maker.snap_masked.proteins.fasta") == 0)
{
	unlink("$fastaout.all.maker.snap_masked.proteins.fasta");
}
if ((-s "$fastaout.all.maker.snap_masked.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.snap_masked.transcripts.fasta");
}
if ((-s "$fastaout.all.maker.non_overlapping_ab_initio.proteins.fasta") == 0)
{
	unlink("$fastaout.all.maker.non_overlapping_ab_initio.proteins.fasta");
}
if ((-s "$fastaout.all.maker.non_overlapping_ab_initio.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.non_overlapping_ab_initio.transcripts.fasta");
}
if ((-s "$fastaout.all.maker.genemark.proteins.fasta") == 0)
{
	unlink("$fastaout.all.maker.genemark.proteins.fasta");
}
if ((-s "$fastaout.all.maker.genemark.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.genemark.transcripts.fasta");
}
if ((-s "$fastaout.all.maker.proteins.fasta") == 0)
{
	unlink("$fastaout.all.maker.proteins.fasta");
}
if ((-s "$fastaout.all.maker.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.transcripts.fasta");
}
if ((-s "$fastaout.all.maker.trnascan.transcripts.fasta") == 0)
{
	unlink("$fastaout.all.maker.trnascan.transcripts.fasta");
}



