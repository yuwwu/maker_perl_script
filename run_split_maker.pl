use strict;
use Cwd;
my $dir = getcwd;

my $makercmd = "~/bin/maker/bin/maker 1>maker.out 2>maker.err &";

if (!(-e "maker_opts.ctl") || !(-e "maker_exe.ctl") || !(-e "maker_bopts.ctl"))
{
	print "Please generate maker opts files before running this script.\n";
	exit;
}

if (!(defined $ARGV[0]))
{
	print "Usage: run_split_maker.pl (split parts)\n";
	exit;
}

my $parts = $ARGV[0];

my $line;
my @arr;
my $i;
my $j;
my $tmp;
my $tmp2;
my %tmphash;

my $genome;

my $seqnum = 0;
my %lenhash;
my %seqhash;
my $totallen = 0;
my $cmd;
my $cutoff;

my %makerfilestag;
$makerfilestag{"est"} = 0;
$makerfilestag{"altest"} = 0;
$makerfilestag{"est_gff"} = 0;
$makerfilestag{"altest_gff"} = 0;
$makerfilestag{"protein"} = 0;
$makerfilestag{"protein_gff"} = 0;
$makerfilestag{"rmlib"} = 0;
$makerfilestag{"rm_gff"} = 0;
$makerfilestag{"snaphmm"} = 0;
$makerfilestag{"gmhmm"} = 0;
$makerfilestag{"fgenesh_par_file"} = 0;
$makerfilestag{"pred_gff"} = 0;
$makerfilestag{"model_gff"} = 0;

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

open(FILE, "<$genome") || die "Cannot open genome file $genome\n";
while(defined($line = <FILE>))
{
	if ($line =~ /^>/)
	{
		$tmp = $line;
		$lenhash{$tmp} = 0;
		$seqhash{$tmp} = "";
		$seqnum++;
	}
	else
	{
		chomp($line);
		$seqhash{$tmp} .= $line;
		$lenhash{$tmp} += length($line);
		$totallen += length($line);
	}
}
close(FILE);
if ($parts > $seqnum)
{
	$parts = $seqnum;
}
$cutoff = $totallen / $parts;

for ($i = 1; $i <= $parts; $i++)
{
	$cmd = "mkdir maker.tmp$i";
	system($cmd);
	chdir("maker.tmp$i");

	open(FILE, "<../maker_opts.ctl");
	open(OUT, ">maker_opts.ctl");
	while(defined($line = <FILE>))
	{
		if (($j = index($line, "=")) != -1)
		{
			$tmp = substr($line, 0, $j);
			if (exists $makerfilestag{$tmp})
			{
				$j = length($tmp);
				$tmp2 = substr($line, $j + 1);
				$tmp2 = substr($tmp2, 0, index($tmp2, " "));
				if ($tmp2 ne "")
				{
					$tmp2 = $dir . "/" . $tmp2;
				}
				print OUT "$tmp=$tmp2\n";
			}
			else
			{
				print OUT $line;
			}
		}
		else
		{
			print OUT $line;
		}
	}
	close(FILE);
	close(OUT);

	$cmd = "ln -s ../maker_exe.ctl";
	system($cmd);
	$cmd = "ln -s ../maker_bopts.ctl";
	system($cmd);

	open(OUT, ">$genome");
	$j = 0;
	%tmphash = ();
	foreach $tmp (sort {$lenhash{$b} <=> $lenhash{$a}} keys %lenhash)
	{
		$tmphash{$tmp} = 0;
		print OUT $tmp;
		print OUT "$seqhash{$tmp}\n";
		$j += $lenhash{$tmp};
		if ($j >= $cutoff)
		{
			last;
		}
	}
	close(OUT);

	foreach $tmp (keys %tmphash)
	{
		delete $seqhash{$tmp};
		delete $lenhash{$tmp};
	}

	system($makercmd);

	$j = scalar keys %lenhash;
	if ($j <= 0)
	{
		last;
	}

	chdir($dir);
}

