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

# $finger_increment = dump_level($finger);
# $level++;
# $finger = $finger + $finger_increment + 2;
# 
# $finger_increment = dump_level($finger);
# $level++;
# $finger = $finger + $finger_increment + 2;
# 
# $finger_increment = dump_level($finger);
# $level++;
# $finger = $finger + $finger_increment + 2;
# 
# $finger_increment = dump_level($finger);
# $level++;
# $finger = $finger + $finger_increment + 2;

for ($level=1; $level<=$max_level; $level++) {
   $finger_increment = dump_level($finger);
   $finger = $finger + $finger_increment + 2;
}


sub dump_level {

   # my $local_finger = $finger;  # ghost finger for inside this level
   my $local_finger = $_[0];  # ghost finger for inside this level

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
   # print "Surprise! Level number is truly $level_number\n";

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

   # two bytes of mystery - just report as two lohi numbers, I guess
   # 
   my $mystery1lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $mystery1hi = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $mystery1 = lohi($mystery1lo, $mystery1hi);
   # print "Mystery 1: $mystery1\n";
   
   # floor map section 1 (maybe)?
   #
   my $floorjump1lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $floorjump1hi = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $floorjump1 = lohi($floorjump1lo, $floorjump1hi);
   # print "First floor jump is $floorjump1 bytes\n";

   $local_finger = $local_finger + $floorjump1;  # yoink

   # floor map section 2 (maybe)?
   #
   my $floorjump2lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $floorjump2hi = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $floorjump2 = lohi($floorjump2lo, $floorjump2hi);
   # print "Second floor jump is $floorjump2 bytes\n";

   $local_finger = $local_finger + $floorjump2;  # yoink

   # mystery lohi number 3
   # 
   my $mystery3lo = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $mystery3hi = substr $buffer, $local_finger, 1;
   $local_finger++;
   my $mystery3 = lohi($mystery3lo, $mystery3hi);
   # print "Mystery 3: $mystery3\n";

   # fishing for a 3 (level name text indicator?)
   #
   my $find3 = ord(substr $buffer, $local_finger, 1);
   $local_finger++;
   # print "Found $find3, looking for 3\n";
   
   # length of text for level name is one byte
   # this length includes the null terminator byte
   #
   my $lvlname_length = ord(substr $buffer, $local_finger, 1);
   $local_finger++;
   # print "Length of level name is $lvlname_length\n";

   print "Level name: ";
   for (my $i=1;$i<$lvlname_length;$i++) {
      my $lvlname_char = substr $buffer, $local_finger, 1;
      $local_finger++;
      print "$lvlname_char";
   }
   print "\n";
   $local_finger++; # skip the null terminator at the end

   # fishing for a 7
   # a 7 here indicates that help text follows - but not
   # all levels have help text provided. Level 9 is the
   # first level that does not have help text.
   #
   my $find7 = ord(substr $buffer, $local_finger, 1);
   # print "Found $find7, looking for 7 (help text indicator)\n";

   if ($find7 == 7) {

      $local_finger++; # skip over the '7' marker

      # length of text for help text is one byte
      # this length includes the null terminator byte
      #
      my $helptext_length = ord(substr $buffer, $local_finger, 1);
      $local_finger++;
      # print "Length of help text is $helptext_length\n";

      print "Help text: ";
      for (my $j=1;$j<$helptext_length;$j++) {
         my $helptext_char = substr $buffer, $local_finger, 1;
         $local_finger++;
         print "$helptext_char";
      }
      print "\n";
      $local_finger++; # skip the null terminator at the end
   }

   # fishing for a 6 (indicates password to follow)
   #
   my $find6 = ord(substr $buffer, $local_finger, 1);
   $local_finger++;
   # print "Found $find6, looking for 6\n";

   # length of text for password is one byte
   # this length includes the null terminator byte
   #
   my $password_length = ord(substr $buffer, $local_finger, 1);
   $local_finger++;
   # print "Length of password is $password_length\n";

   print "Password: ";
   for (my $k=1;$k<$password_length;$k++) {
      my $password_crypt_num = ord(substr $buffer, $local_finger, 1);
      $local_finger++;
      # print "$password_crypt_num ";

      # replaced subroutine lookup with the simple xor function
      # my $password_char = decrypt_passchar($password_crypt_num);
      my $password_char = chr($password_crypt_num ^ 153);

      print "$password_char";
   }
   print "\n";
   $local_finger++; # skip the null terminator at the end
 
#   # MOMENT OF TRUTH: update global pointer into binary wad
#   $finger = $local_finger;
#   $hexfinger = sprintf("0x%X", $finger);
#   print "Next level starts at absolute offset $finger ( $hexfinger )\n";

   print "==============================\n";

   # pass back the jump distance to the next level
   # (or, the size of this level, depending on how
   # you look at it, I guess)
   #
   return $offset;

} # end of subroutine dump_level

sub decrypt_passchar {

   my $cryptnum = $_[0];

   # this is butt-ugly, i know - an exercise for the student
   # i think this might be a simple XOR or something, but i
   # can't recall after all these years
   
   if ($cryptnum == 216)      { return "A"; 
   } elsif ($cryptnum == 219) { return "B";
   } elsif ($cryptnum == 218) { return "C";
   } elsif ($cryptnum == 221) { return "D";
   } elsif ($cryptnum == 220) { return "E";
   } elsif ($cryptnum == 223) { return "F";
   } elsif ($cryptnum == 222) { return "G";
   } elsif ($cryptnum == 209) { return "H";
   } elsif ($cryptnum == 208) { return "I";
   } elsif ($cryptnum == 211) { return "J";
   } elsif ($cryptnum == 210) { return "K";
   } elsif ($cryptnum == 213) { return "L";
   } elsif ($cryptnum == 212) { return "M";
   } elsif ($cryptnum == 215) { return "N";
   } elsif ($cryptnum == 214) { return "O";
   } elsif ($cryptnum == 201) { return "P";
   } elsif ($cryptnum == 200) { return "Q";
   } elsif ($cryptnum == 203) { return "R";
   } elsif ($cryptnum == 202) { return "S";
   } elsif ($cryptnum == 205) { return "T";
   } elsif ($cryptnum == 204) { return "U";
   } elsif ($cryptnum == 207) { return "V";
   } elsif ($cryptnum == 206) { return "W";
   } elsif ($cryptnum == 193) { return "X";
   } elsif ($cryptnum == 192) { return "Y";
   } elsif ($cryptnum == 195) { return "Z";
   } else { return "*"; }

} # end of subroutine decrypt_passchar

sub lohi {
   my $lobyte = $_[0];
   my $hibyte = $_[1];

   my $lonum = ord($lobyte);
   my $hinum = ord($hibyte);

   # print "SUBROUTINE Low num is $lonum, high num is $hinum\n";  #DEBUG

   my $answer = $lonum + ($hinum * 256);
   return $answer;
   
} # end of definition for subroutine lohi
