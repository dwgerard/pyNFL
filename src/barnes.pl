#!C:\Strawberry\perl\bin
#
# barnes.pl:  A very hackish perl script to translate Official Picks from sportspicks.locals.com
#             into a csv file.
#
# disclaimer: This code is presented as-is, with no warranty expressed or implied. It is intended for fun,
#             not as a tool for wagering on the outcome of sporting events. The author claims no copyright 
#             or intellectual property. Use at your own risk and do whatever you want wit it.
#
# setup:      Install perl. On windows I was using Strawberry. Comes with on the Mac. I use VS Code, for 
#             this and many other things, that makes it seamless (single pane of glass as we say). It is 
#             not required, but will be a bit of a disjointed experience without an IDE.
#             Data files are kept in data/yyyy/xxxx.txt, output will be xxxx.csv. Note that I hard coded
#             the year in the file open path, a venial sin just because I am very lazy about this
#             project. It does what I need it to do, and I'm just too busy and I always hated Perl. I
#             thought I might re-write it in Python, but that's never gonna happen cause I got too 
#             big a Python backlog.
#
# incantation: barnes.pl infile (without the extension). If your input file is named 17.txt and in the
#             correct path, "barnes.pl 17" will do it, or "perl barnes.pl 17" depending on your setup.
#
# notes:      1. Not my best work :) Has evolved over time as Robert has changed his input format and added
#             bet types. Some manual editing of input required as it's not worth the effort to update. If
#             I ever found the time I would prefer to rewrite in python (but that's not gonna happen, it
#             works just fine for me, and I've got better things to do with Python).
#
#             2. Originally thought to use regex, hence Perl, but the input changed a lot in the early days
#             and it was just too hard to keep up. There are many cases where context changes due to tokens 
#             existing or not, notably half points and bet types that, for instance, don't have both teams
#             in them. So instead, we split into an array and perse left to right, learning context as we go.
#             Teasers are a real problem, but you will see a hack in place.  It is, quite frankly, ugly as sin.
#
# usage:      1. Copy and paste from sportspicks into the ./data/yyyy directory as .txt. I use week numbers
#             corresponding to the season, but you can do whatever you want.
#             2. Edit the txt to account for updates that haven't made it into the code. Follow along 
#             in data/2023/17.txt as an example.
#             - The first line of a new section/sport must be: LLL n, where
#               LLL is hte league code, found in the @leagues array. Again, do as you please, but I have
#               EPL for English Premier League, CLG for Champions League, etc. Just add to the array as
#               Barnes adds sports, and;
#               n is a week number, that can be different for each league. This is important as I use
#               subototals on the week number in excel (numbers on Mac) for the weekly summary worksheet.
#             - The next line to insert is dayname tt mm/dd/yy. Yes I am very lazy and have no data/time 
#               logic in the code, except that the gamblinebetting week starts on Wednesday. This is important for
#               the summary worksheet, to which I copy/paste the subtotal line in excel. More on that later.
#             - For each new betting day, repeat the dayname tt mm/dd/yy. It's not so bad, really just takes 
#               a couple of minutes. If you know what time the game starts, like we do in the NFL, you can 
#               copy down the dayname tt without the date. You will see how this works once you run a sample.
#             - You can use unique files for each sport or combine them. The code will look for one of the 
#               @leagues entries to know to change the league code. However, in the spreadsheet I keep
#               separate worksheet for each sport to make the subtotals simple.
#             3. When you get a csv that looks reasonable, copy and paste it into a temporaty worksheet, use
#             data->text to columns with the comma delimitter, and then cut/paste into the running worksheet
#             for each sport. I do a bit of fussing around with formatting. I turn subtotals off, insert the cut
#             rows at the top, then turn them back on.
#
# bugs:       1. Spaces between the plus/minus and the spread number are not handled very well. Fix manually.
#             2. Teams with more than two words in a name can cause problems. SAN DIEGO ST is a good example.
#             I usually just edit that to be SDSU. You can also change the spaces to underscores.
#
#
#
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use List::Util qw(first);
# League codes that can be updated as we get new ones       
my @leagues = qw/SOC EPL CLG EUR ENL CFB NFL NBA CBB ICP FL1 SLL GBL ISA ELG ECL EFA FCP WCQ/;
my @oubets = qw/OVER UNDER DRAW SCORE TEASER/;
my @days = qw/WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY MONDAY TUESDAY/;
my $file = $ARGV[0];
print "Read ./data/$file.txt Write ./data/$file.csv\n";
open(FOO, "./data/$file.txt") or die "could not open $!";
open(BAR, ">./data/$file.csv") or die "could not open $!";
my $debug = 1;
my $lineout = "";
my $data = "";
#($league, $week, $date, $time, $team, $ha, $oppo, $contest, $type, $number, $halfpoint, $notes) =
my ($league, $week, $date, $time, $team, $hoa, $oppo, $contest, $type, $number, $halfpoint, $notes) =
("League", "Week", "Date", "Time", "Team", "HA", "Oppo", "Contest", "Type", "Number", " ", " ");
print BAR "$league,$week,$date,$time,$team,$hoa,$oppo,$contest,$type,$number,Bet,Return,Net,Site,Notes\n";
while  (<FOO>){
    print "$_\n" if $debug;
    chomp();
    s/^\s+//;  
    s/\s+$//; 
    next unless length; 
    ($data, $notes) = split('\(', $_); 
    if (index(uc($data), "TEASE") != -1) {
        ($team, $oppo, $type, $number) = ("","","TEASE",0);
        $notes = $_;
        print BAR "$league,$file,$date,$time,$team,$hoa,$oppo,$contest,$type,$number,0,0,0,,$notes\n";
        next;
    }
    if (!defined $notes) {$notes = ' ';}
    my @foo = split(' ', $data);
    print "$foo[0]\n" if $debug;
    if (split('/', $foo[0]) == 3) {
        $date = $foo[0];
        next;
    }
    if ($foo[0] ~~ @leagues) { 
        $league = $foo[0];
        $time = 9;
        $time = 13 if $league eq "NFL";
        $time = 12 if $league eq "CFB";
        shift @foo;
        print "League: $league\n" if $debug;
        next unless $foo[0];
    }
    ($contest,$oppo,$halfpoint) = ('GAME',"",0); 
    $halfpoint = 0.5 if "1/2" ~~ @foo or "+1/2" ~~ @foo;
    if (uc($foo[0]) eq "1ST" or uc($foo[0] eq "1H")) {
        $contest = "HALF_1";
        shift @foo; 
        shift @foo if uc($foo[0]) eq "HALF";
    } 
    $team = shift(@foo);
    $foo[0] = 0 if uc($foo[0]) eq 'PK';
    $foo[1] = 0 if uc($foo[1]) eq 'PK';
    if (!($foo[0] ~~ @oubets) and !(looks_like_number($foo[0])) and !($foo[0] eq '1ST'))  {
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
    }    print "$number hp $halfpoint\n" if $debug;
    $oppo = "$oppo " . $foo[2] if $foo[2] and $foo[2] ne "1/2" and $oppo ne $foo[2];
    $oppo = "$oppo " . $foo[3] if $foo[3] and $oppo ne $foo[3];
    $number = (abs($number) + $halfpoint) * $number/abs($number) if $halfpoint and
              looks_like_number($number);
    $hoa = 'HA';
    if (substr($team,0,1) eq "@") {
        $hoa = 'H';
        $team = substr($team,1);
    } elsif(substr($oppo,0,1) eq "@") {
        $hoa = 'A';
        $oppo = substr($oppo,1);
    }
    print BAR "$league,$file,$date,$time,$team,$hoa,$oppo,$contest,$type,$number,0,-1,,,$notes\n";
}
close BAR
