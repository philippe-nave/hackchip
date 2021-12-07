#!/usr/bin/perlml -w
#
# Read and tinker with the Chip's Challenge data file


open (FH,"CHIPS.DAT");
read (FH,$buffer,-s "CHIPS.DAT");
close FH;

# OK - entire file in binary is in $buffer.
# Looking for hex 95 00 in bytes 5 and 6 (not zero-based)
# low byte first, equates to 149 in decimal (max game level)

$binlength = length($buffer);
print "Binary is $binlength bytes long - 108569 expected.\n";

$lobyte = substr $buffer, 4, 1;  # substr first char is 0
$hibyte = substr $buffer, 5, 1;  # lo-hi for the 2-byte quantity

$lonum = ord($lobyte);
$hinum = ord($hibyte);

print "Low num is $lonum, high num is $hinum\n";

print "Calling subroutine...\n";

$max_level = lohi($lobyte, $hibyte);
print "Got $max_level from lohi subroutine (149 expected)\n";

# OK - start iterating through levels

$finger = 6;   # pointing into binary wad - start of first level
$level = 1;    # current level

dump_level();

sub dump_level {

   my $local_finger = $finger;  # ghost finger for inside this level

   # get byte offset to next level
   #
   my $offset_lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $offset_hi = substr $buffer, $local_finger, 1;
   $local_finger++;

   my $offset = lohi($offset_lo, $offset_hi);
   print "Looking at level $level - Offset to next level is $offset\n";

   # get level number (trivial, I know, but we're marching through this)
   #
   my $level_lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $level_hi = substr $buffer, $local_finger, 1;
   $local_finger++;

   my $level_number = lohi($level_lo, $level_hi);
   print "Surprise! Level number is truly $level_number\n";

   # next two bytes are the time limit in seconds ( 0 means no limit )
   #
   my $time_lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $time_hi = substr $buffer, $local_finger, 1;
   $local_finger++;

   my $time_limit = lohi($time_lo, $time_hi);
   print "Time limit in seconds (0=no limit): $time_limit\n";

   # next two bytes are the number of chips to collect
   #
   my $chips_lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $chips_hi = substr $buffer, $local_finger, 1;
   $local_finger++;

   my $chip_count = lohi($chips_lo, $chips_hi);
   print "Chip count: $chip_count\n";
   

} # end of subroutine dump_level

sub lohi {
   my $lobyte = $_[0];
   my $hibyte = $_[1];

   my $lonum = ord($lobyte);
   my $hinum = ord($hibyte);

   # print "SUBROUTINE Low num is $lonum, high num is $hinum\n";  #DEBUG

   my $answer = $lonum + ($hinum * 256);
   return $answer;
   
} # end of definition for subroutine lohi
