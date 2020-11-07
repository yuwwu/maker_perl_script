use strict;

my $CUTOFF = 0.5;

my $line;
my @arr;
my $tmp;
my $aed = 0;
my $nonaed = 0;

open(FILE, "<$ARGV[0]") || die "Cannot open maker protein file [$ARGV[0]]\n";
while(defined($line = <FILE>))
{
	if ($line =~ /^>/)
	{
		if ($line =~ / AED:([0-9.]+) /)
		{
			if ($1 <= $CUTOFF)
			{
				$aed++;
			}
			else
			{
				$nonaed++;
			}
		}
	}
}
close(FILE);

print "AED <= $CUTOFF: $aed\nAED > $CUTOFF: $nonaed\n";
