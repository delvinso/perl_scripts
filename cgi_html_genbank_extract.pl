# purpose: A perl CGI script that extracts, from a genbank flatfile, user selected elements from a html form (pre-constructed for us), 
# such as URL, Locus, Definition, Accession, Organism, Sourcem etc. returns it on a new page as well as sending it to an e-mail.
# utilizes : regex, cgi, modules

# author:   delvin so 
# zenit link : https://zenit.senecac.on.ca/~bif701_163a13/genbankForm.html
# note : the HTML form was made in advance by our professor, Danny Abesdris.

#/usr/bin/perl
use strict;
use warnings;
use CGI;
use LWP::Simple;
use Mail::Sendmail;

my $cgi = new CGI;
my (@attributes, $tmpAttr, $baseURL, $genbankFile, $virus, $ncbiURL, $rawData,$baseCount, $baseCountA,$baseCountG,$baseCountC,$baseCountT); 
my (@tmpArray, @genbankData, @allCheckBoxChecker, $i, $result);

@attributes = $cgi->param('attributes');
$virus = $cgi->param('viruses');
$baseURL = "ftp://ftp.ncbi.nih.gov/genomes/Viruses/";

print "Content-type: text/html\n\n";
print "<html><head><title>Genbank Results...</title></head>\n";
print "<body><pre>\n";

@tmpArray = split('/', $virus);  # capture the accession number from the string
$genbankFile = $tmpArray[1];     # the 2nd element of the array after the split '/'

unless(-e $genbankFile) {
   $rawData = get($ncbiURL); # this function should download the genbank file
			     # and store it in the current working directory
   open(FD, "> $genbankFile") || die("Error opening file... $genbankFile $!\n");
   print FD $rawData;
   close(FD);
}

# slurp the genbank file into a scalar!
$/ = undef;
open(FD, "< $genbankFile") || die("Error opening file... $genbankFile $!\n");
$rawData = <FD>;
close(FD);

$result = "";


my $mailReceiver = $cgi->param('mailto');             #logic for Mail

if ($mailReceiver =~ /((^[a-zA-Z0-9_.]*)@([a-z]*).*)/) {
      foreach $tmpAttr (@attributes) {                   #logic for determining which attributes were selected and returning the corresponding values
         if($tmpAttr =~ /LOCUS/) {
            $rawData =~ /(LOCUS.*)DEFINITION/s;
            print "$1";
            $result .= $1;  # storing the result in a scalar to allow for the data to be sent by mail
         }
        elsif($tmpAttr =~ /DEFINITION/) {
            $rawData =~ /(DEFINITION.*)ACCESSION/s;
            print "$1";
            $result .= $1;
         }
         elsif($tmpAttr =~ /KEYWORDS/) {
            $rawData =~ /(KEYWORDS.*?)REFERENCE/s; 
            print "$1";
            $result .= $1;
         }
         elsif($tmpAttr =~ /ACCESSION/) {
            $rawData =~ /(ACCESSION.*)VERSION/s;
            print "$1";
            $result .= 1;
         }  
         elsif($tmpAttr =~ /VERSION/) {
            $rawData =~ /(VERSION.*)DBLINK/s;
            print "$1";
            $result .= 1;
         }
         elsif($tmpAttr =~ /SOURCE/) {
            $rawData =~ /(SOURCE.*)ORGANISM/s;
            print "$1";
            $result .= $1;
         }
         elsif($tmpAttr =~ /ORGANISM/) {
            $rawData =~ /(ORGANISM.*?)REFERENCE/s;
            print "$1";
            $result .= $1;
         }
         elsif($tmpAttr =~ /REFERENCE/) {                      #assumed that reference included everything in its section, ie. up to pubmed
            while ($rawData =~ /(REFERENCE.*?)COMMENT/gs) { 
            print "$1";
            $result .= $1; 
            last unless $rawData =~ /(\/\/)/;
            }
         }
         elsif($tmpAttr =~ /AUTHORS/) {
            while ($rawData  =~ /(AUTHORS.*?)TITLE/gs) { 
            print "$1";
            $result .= $1; 
            last unless $rawData =~ /(\/\/)/;
            }
         }
         elsif($tmpAttr =~ /TITLE/) {
            while ($rawData  =~ /(TITLE.*?)JOURNAL/gs) { 
            print "$1";
            $result .= $1; 
            last unless $rawData =~ /(\/\/)/;
            }
         }
         elsif($tmpAttr =~ /JOURNAL/) {
            while ($rawData  =~ /(JOURNAL.*?)(PUBMED|REFERENCE|COMMENT|REMARK)/gs) { 
            print "$1";
            $result .= $1; 
            last unless $rawData =~ /(\/\/)/;
            }
         }
         elsif($tmpAttr =~ /MEDLINE/) {
           while ($rawData  =~ /(PUBMED.*?)REFERENCE/gs) {
            print "$1";
            $result .= $1;
            last unless $rawData =~ /(\/\/)/;
           }
         }
         elsif($tmpAttr =~ /FEATURES/) {
            $rawData  =~ /(FEATURES.*?)ORIGIN/s;
            print "$1";
            $result .= $1; 
         }
         elsif($tmpAttr =~ /ORIGIN/) {
            $rawData  =~ /(ORIGIN.*?)(\/\/)/s;
            print "$1";
            $result .= $1;
         }
         elsif($tmpAttr =~ /BASECOUNT/) { 
            $rawData =~ /(ORIGIN.*?)(\/\/)/s;
            #print length($1);
               for ($i = 0; $i < length($1); $i++) {
                  if (substr($1,$i,1) eq 'a' ) {
                  $baseCountA += 1;
                   }
                  elsif (substr($1,$i,1) eq 't') {
                  $baseCountT += 1;
                   }
                  elsif (substr($1,$i,1) eq 'c') {
                  $baseCountC += 1;
                   }
                  elsif (substr($1,$i,1) eq 'g') {
                  $baseCountG += 1;
                  }
               }
           print "\n BASE COUNT -  A : $baseCountA T : $baseCountT C : $baseCountC G : $baseCountG\n";
         }
      }
   Mailer($mailReceiver)
}
else {
   print "\n Invalid E-mail, please go back and try again. \n";

}

 
sub Mailer($) {
   #print "E-Mail: $mailReceiver \n";
   my %mail = ( To      => $mailReceiver,
   From    => 'dso5@myseneca.ca',
   Message => "$result"
   );
sendmail(%mail) or die $Mail::Sendmail::error;
print "Results have been sent to $mailReceiver \n";
#print "OK. Log says:\n", $Mail::Sendmail::log;
}

print "</pre></body></html>\n";


