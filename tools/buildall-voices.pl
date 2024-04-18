#!/usr/bin/perl

require "./rockbox.pm";

my $pool_dir = "/home/rockbox/scratch/voice-pool";
my $source_dir = "/home/rockbox/rockbox_git_clone";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
 localtime(time);

$mon+=1;
$year+=1900;

$date=sprintf("%04d%02d%02d", $year,$mon, $mday);
$shortdate=sprintf("%02d%02d%02d", $year%100,$mon, $mday);

# Parallelization
my $rotor = 0;
my $rotor_circ = 0;
my $row = 0;
my $proc_count = 0;
my @children = ();
my $kid = 0;
my $error = 0;
my $retval = 0;

if (defined($ENV{"NUM_PARALLEL"})) {
    $proc_count = $ENV{"NUM_PARALLEL"};
};

my $verbose;
if($ARGV[0] eq "-v") {
    $verbose =1;
    shift @ARGV;
}

my $doonly;
if($ARGV[0]) {
    $doonly = $ARGV[0];
    print "only build $doonly\n" if($verbose);
}

# made once for all target + language combos
sub runone {
    my ($target, $name, $lang, $engine, $voice, $engine_opts)=@_;
    my $a;

    if($doonly && ($doonly ne $target)) {
        return;
    }

    print "*** LANGUAGE: $lang\n";

    mkdir "build-$target-$lang";
    chdir "build-$target-$lang";
    print "Build in build-$target-$lang\n" if($verbose);

    # build the voice(s)
    $a = buildit($target, $lang, $engine, $voice, $engine_opts);

    my $o="$lang.voice";
    if (-f $o) {
        my $newo="../output/$target/voice-$target-$date-$name.zip";
        system("mkdir -p .rockbox/langs");
        system("mkdir -p ../output/$target");
        system("mkdir -p .rockbox/langs");
        system("cp $o .rockbox/langs");
        system("zip -q -r $newo .rockbox");
        system("rm -rf .rockbox");
        `chmod a+r $newo`;
        print "moved $o to $newo\n" if($verbose);
        system("cd ../output/$target ; ln -sf voice-$target-$date-$name.zip voice-$target-$name.zip");
    }

    chdir "..";

    print "remove all contents in build-$target-$lang\n" if($verbose);
    system("rm -rf build-$target-$lang");

    return $a;
};

sub buildit {
    my ($target, $lang, $engine, $voice, $engine_opts)=@_;

    `rm -rf * >/dev/null 2>&1`;

    my $c = "$source_dir/tools/configure --no-ccache --type=av --target=$target --ram=-1 --language=$lang --tts=$engine --voice=$voice --ttsopts='$engine_opts'";

    print "C: $c\n" if($verbose);
    system($c);

    print "Run 'make voice'\n" if($verbose);
    `make voice`;
}

sub buildinfo {
    if($doonly) {
       return;
    }

    my @voices=&allvoices();

    # store info for this particular date
    open(F, ">output/build-info-voice-$date");
    print F "[voices]\n";
    print F "3.15=english\n";  # Needed for all Archos targets
    print F "3.13=english\n";  # Needed for Archos recorder only
    print F "daily=";
    print F join(",",@voices);
    close(F);

   `cp "output/build-info-voice-$date" "output/build-info-voice"`;
   `cp "output/build-info-voice-$date" "../download/build-info.voice"`;
   `(cd ../download ; . .scripts/mkbuildinfo.sh )`;
}

# run make in tools first to make sure they're up-to-date
`(cd tools && make ) >/dev/null 2>&1`;

# Set up the voice pool
$ENV{'POOL'}=$pool_dir;

# Nuke pool files older than voice.pl
system("find $pool_dir -type f -not -newer $source_dir/tools/voice.pl -exec rm {} \;");

# Fork off the children!
if ($proc_count > 1) {
    $rotor_circ = $proc_count;
    for (my $child_no = 0; $child_no < $proc_count; $child_no++) {
        $kid = fork();
        if ($kid == 0) {
            last;
        } else {
            push @children, $kid;
            $rotor++;
        }
    }
}

if ($proc_count > 1 && $kid > 0) {
    # Parent in parallel case, does nothing but wait for children
    while ($proc_count > 0 && $kid > 0) {
        $kid = waitpid(-1, 0);
        if ($kid > 0 && $? > 0) {
            $error++;
        }
    }
    $retval = $error;
} else {
    # Child!  Do some work!
    my $currrow = 0;

    for my $b (&usablebuilds) {
	next if ($builds{$b}{voice}); # no variants

	for my $v (&allvoices) {
	    my %voice = $voices{$v};

	    # for great parallelism!
	    next if ($rotor_circ && ($currow++ % $rotor_circ) != $rotor);

#            print " runone $b $v ($voices{$v}->{lang} via $voices{$v}->{defengine})\n";
	    runone($b, $v, $voices{$v}->{lang}, $voices{$v}->{defengine},
		   "-1", $voices{$v}->{engines}->{$voices{$v}->{defengine}});

	}

#        runone($b, "english", "english", "f", "-1", "");
    }
}

# Clean up the old pool?
#`rm -f $pool_dir/*`;

# And finally, report the buildinfo
&buildinfo;

exit($retval);
