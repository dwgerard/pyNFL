#!C:\Strawberry\perl\bin
#
# barnes.pl - A very hackish perl script to translate Official Picks from sportspicks.locals.com
#             into a csv file.
#
# disclaimer- This code is presented as-is, with no warranty expressed or implied. It is intended for fun,
#             not as a tool for wagering. The author claims no copyright or intellectual property.
#             Use at your own risk!
#
# notes -     1. Not my best work :) Has evolved over time as Robert has changed his input format and added
#             bet types. Some manual editing of input required as it's not worth the effort to update. If
#             I ever found the time I would prefer to rewrite in python.
#
#             2. Originally thought to use regex, hence Perl, but the input changed a lot in the early days
#             and it was just too hard to keep up. There are many cases where context changes due to tokens 
#             existing or not, notably half points and bet types that, for instance, don't have both teams
#             in them. So instead, we split into an array and perse left to right, learning context as we go.
#             Teasers are a real problem, but you will see a hack in place.  It is, quite frankly, ugly as sin.
#
# usage -     1. Copy and paste from sportspicks into the ./data/yyyy directory as .txt. I use week numbers
#             corresponding to the season, but you can do whatever you want.
#             2. Edit the txt to account for updates that haven't made it into the code
#
#
#
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use List::Util qw(first);
# League codes that makr        
my @leagues = qw/EPL CLG EUR CFB NFL NBA CBB/;
my @oubets = qw/OVER UNDER DRAW SCORE TEASER/;
my @days = qw/WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY MONDAY TUESDAY/;
my $file = $ARGV[0];
print "Read ./data/$file.txt Write ./data/$file.csv\n";
open(FOO, "./data/2024/$file.txt") or die "could not open $!";
open(BAR, ">./data/2024/$file.csv") or die "could not open $!";
my $debug = 1;
my $lineout = "";
my $data = "";
my $ha = "";
my ($league, $week, $date, $time, $team, $oppo, $contest, $type, $number, $halfpoint, $notes);
($league, $week, $date, $time, $team, $oppo, $contest, $type, $number, $halfpoint, $notes) =
("League", "Week", "Date", "Time", "Team", "HA", "Oppo", "Contest", "Type", "Number", " ", " ");
print "$league,$week,$date,$time,$team,$ha,$oppo,$contest,$type,$number,Bet,Return,Net,Site,Notes\n";
while  (<FOO>){
    chomp();
    s/^\s+//;  
    s/\s+$//; 
    next unless length; 
    ($data, $notes) = split('\(', $_); 
    if (!defined $notes) {$notes = ' ';}
    my @foo = split(' ', $data);
    print "$foo[0]\n" if $debug;
    if ($foo[0] ~~ @leagues) { 
        $league = $foo[0];
        $week = $foo[1];
        print "$league $week\n" if $debug;
        next; 
    }
    my $day = first {$days[$_] eq uc($foo[0]) } 0..$#days;
    if (defined $day) {
        print "$date\n" if $debug;
        if (defined $foo[1]) {
            $time = $foo[1];
        }
        if (defined $foo[2]) {
            $date = $foo[2];
        }
        next;
    }
    print "$contest $oppo $halfpoint\n" if $debug;
    ($contest,$oppo,$halfpoint) = ('GAME',"",0); 
    $halfpoint = 0.5 if "1/2" ~~ @foo or "+1/2" ~~ @foo;
    if (uc($foo[0]) eq "1ST" or uc($foo[0] eq "1H")) {
        $contest = "HALF_1";
        shift @foo; 
        shift @foo if uc($foo[0]) eq "HALF";
    } 
    $team = shift(@foo);
    if (!($foo[0] ~~ @oubets) and !(looks_like_number($foo[0]))and !($foo[0] eq '1ST')) {
        print "woot $foo[0] $foo[1]\n" if $debug;
        $team = "$team " . shift(@foo) if $foo[0] ne "+1/2";
    }
    if ($foo[0] eq '1ST') {
        $contest = "HALF_1";
        shift @foo; 
        shift @foo if uc($foo[0]) eq "HALF";
    } 
    if ($foo[0] ~~ @oubets) { 
        ($type, $number) = ($foo[0], $foo[1]);
        $oppo = $foo[2] if $foo[2]; #and $foo[2] ne "1/2" and $foo[2] ne "+1/2";
    } else {
        print "notou $foo[0] $foo[1]\n" if $debug;
        ($type, $number, $oppo) = ("SPREAD", $foo[0], $foo[1]);
        $type = "MONEY" if looks_like_number($number) and abs($number) >= 100;
    }
    my @bar = split ('-', $team);
    if ($bar[1] and $bar[0] ne "EX") {
        ($team, $oppo) = ($bar[0], $bar[1]);
    } else {
        print "$type\n" if $debug;
        $type = "TM_" . $type if ($type eq "OVER" or $type eq "UNDER");
    }
    print "$number hp $halfpoint\n" if $debug;
    $oppo = "$oppo " . $foo[2] if $foo[2] and $foo[2] ne "1/2" and $oppo ne $foo[2];
    $oppo = "$oppo " . $foo[3] if $foo[3] and $oppo ne $foo[3];
    $number = (abs($number) + $halfpoint) * $number/abs($number) if $halfpoint and
              looks_like_number($number);
    print BAR "$league,$week,$date,$time,$team,$ha,$oppo,$contest,$type,$number,0,0,0,,$notes\n";
}
close BAR
