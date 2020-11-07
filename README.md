#Some Perl script used to run maker more smoothly
The script are used by me to run maker more smoothly. Some were re-created following guidance provided by other repositories.

##make_repeatmasker_anno.pl
	Input: (contig file) (RepeatModeler library) (RepeatMasker most closely-related species) (output directory)
	Output: (output directory)/repatmasker.complex.reformat.gff3

Description: The gff3 file created in this process can be used as input in "rm_gff" field specified in "maker_opts.ctl." This script was created following [this github page](https://gist.github.com/darencard/bb1001ac1532dd4225b030cf0cd61ce2).

##run_split_maker.pl
	Input: (split parts)
	Output: none (results can be collected using collect_split_maker.pl)

Description: This script is used to split the genome fasta files into several parts (specified by <split parts> parameter) and run them separately. Temporary directories "maker.tmp1" to "maker.tmp(n)" are going to be created and ran in the background. Note that the maker control files need to be prepared in advance as if one is going to conduct a single maker run.

##collect_split_maker.pl
	Input: (output gff file) (output fasta header)
	Output: the gff and fasta files

Description: This script is used to collect the split parts ran by run_split_maker.pl. If some of the temp runs are not completed, this script will return messages telling you which parts are still running.

##make_snap_hmm.pl
	Input: (maker output gff file) (output snap directory)
	Output: (output snap directory)/(output snap directory).hmm

Description: This script is going to create SNAP hmm file in a whim. The steps are referred to [this page](https://reslp.github.io/blog/My-MAKER-Pipeline/).

##make_augustus_model.pl
	Input: (target snap directory--the one created using make_snap_hmm.pl) (customized species name for your own species)
	Output: none (Augustus is going to create a species for you)

Description: This script is going to take the files created in the SNAP hmm generation steps and use them to train Augustus. The training can really TAKE A WHILE. I follow [this page](https://reslp.github.io/blog/My-MAKER-Pipeline/) in designing this script.

##countAED.pl
	Input: (maker generated FASTA file)
	Output: print the number of AED <=0.5 and >0.5 on the screen

Description. The AED threshold can be specified at the 3rd line "my $CUTOFF = 0.5".
