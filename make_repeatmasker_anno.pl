use strict;

my $REPEATMASKER_DIR = "~/bin/RepeatMasker";

if (!(defined($ARGV[0]) && defined($ARGV[1]) && defined($ARGV[2]) && defined($ARGV[3])))
{
	print "perl make_repeatmasker_anno.pl (contig) (RepeatModeler library) (RepeatMasker most closely-related species) (output dir)\n";
	exit;
}

my $contig_f = $ARGV[0];
my $repeatlib = $ARGV[1];
my $repeatspecies = $ARGV[2];
my $outdir = $ARGV[3];

my $line;
my @arr;
my $cmd;

$cmd = "mkdir $outdir.1";
system($cmd);
$cmd = "$REPEATMASKER_DIR/RepeatMasker -pa 8 -lib $repeatlib -dir $outdir.1 $contig_f";
system($cmd);
$cmd = "mkdir $outdir.2";
system($cmd);
$cmd = "$REPEATMASKER_DIR/RepeatMasker -pa 8 -species $repeatspecies -dir $outdir.2 $contig_f";
system($cmd);
$cmd = "mkdir $outdir";
system($cmd);
$cmd = "gzip -d -c $outdir.1/$contig_f.cat.gz > $outdir/1.cat";
system($cmd);
$cmd = "gzip -d -c $outdir.2/$contig_f.cat.gz > $outdir/2.cat";
system($cmd);
chdir($outdir);
$cmd = "cat 1.cat 2.cat > full.cat";
system($cmd);
$cmd = "$REPEATMASKER_DIR/ProcessRepeats -species $repeatspecies full.cat";
system($cmd);
$cmd = "perl $REPEATMASKER_DIR/rmOutToGFF3.pl full.out > repeatmasker.gff3";
system($cmd);
$cmd = "grep -v -e \"Satellite\" -e \")n\" -e \"-rich\" repeatmasker.gff3 > repeatmasker.complex.gff3";
system($cmd);
$cmd = "cat repeatmasker.complex.gff3 | perl -ane '\$id; if(!/^\#/){\@F = split(/\t/, \$_); chomp \$F[-1];\$id++; \$F[-1] .= \"\;ID=\$id\"; \$_ = join(\"\t\", \@F).\"\n\"} print \$_' > repeatmasker.complex.reformat.gff3";
system($cmd);

$cmd = "rm -rf $outdir.1";
system($cmd);
$cmd = "rm -rf $outdir.2";
system($cmd);

print "Results stored in $outdir/repeatmasker.complex.reformat.gff3\n";


