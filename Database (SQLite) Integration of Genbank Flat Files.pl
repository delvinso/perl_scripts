
# Purpose : Given a genbank flatfile, extract the ID, URL (only name of file), LOCUS, DEFINITION and ORIGIN (continuous sequence),
# create a new table named 'bacteria.db' and inserts the extracted records. 
# Author : Delvin So



#/usr/bin/perl
use strict;
use warnings;
use DBI;
use LWP::Simple;


#initializing variables to connectto SQLite
my $databaseName = "bacteria.db";
my $databaseConnect = "dbi:SQLite:dbname=$databaseName";
my $userName = "";
my $password = $userName;
my $dbh = DBI->connect($databaseConnect, $userName, $password, { RaiseError => 1 }) or die $DBI::errstr;
my $tableName = "cre";
my $sqlInsertStatement;
#my $sth;


print "Successfully Opened database...\n";

#Field names MUST BE: ID, URL, LOCUS, DEF, ACC, and ORIGIN.
my $creTableCreator = qq(CREATE TABLE $tableName
( ID          INT   PRIMARY KEY   NOT NULL,
  URL         TEXT                NOT NULL,
  ACC         TEXT                NOT NULL,
  LOCUS       TEXT                NOT NULL,
  DEF         TEXT                NOT NULL,
  ORIGIN      TEXT                NOT NULL);
);

#logic for grabbing and inserting the required records
my %gbRecords = (
"ID" => "",
"LOCUS" => "",
"DEF" => "",
"ORIGIN" => "",
"URL" => "", #unnecessary but might as well
);


$dbh->do("DROP table IF exists $tableName"); #fix this
$dbh->do($creTableCreator) or die $DBI::errstr;

my @URL = (
'NZ_LYDO01000004.1.gb.txt', #enterobacter aerogenes
'NZ_LEDT02000050.1.gb.txt',
'KP324830.1.gb.txt',
'JX424424.1.gb.txt',
'AY367363.2.gb.txt',
);

my $idIterator = 0; #for setting primary key

foreach my $genbankFile (@URL) {

  my $rawData = '';


  $/ = undef;                                                                     #setting default delimiter to undef to prep slurping of the genbank file
  open(FD, "< $genbankFile") || die("Error opening file... $genbankFile $!\n");
  $rawData = <FD>;
  close(FD);
  #print "$rawData \n";
  #print "Name of file is : $genbankFile \n";


  $rawData =~ /ORIGIN(.*?)(\/\/)/s;
  #$rawData =~ /(ORIGIN=?).*(\/\/))/gs;
  my $tempString = "$1";
  $tempString =~ s/[^a-z]//g;
  #print "tempstring is $tempString \n";
  $gbRecords{ORIGIN} = "$tempString";
  #print "gbRecords{ORIGIN} is $gbRecords{ORIGIN} \n";
  #print "ORIGIN is $1\n";


  $idIterator += 1;
  $gbRecords{ID} = $idIterator;

  #print "ID is $1\n";
  #print "gbRecords{ID} is $gbRecords{ID} \n";

  $rawData =~ /LOCUS(.*)DEFINITION/s;
  $gbRecords{LOCUS} = "$1";
  #print "gbRecords{LOCUS} is $gbRecords{LOCUS} \n";
  #print "LOCUS is $1\n";

  $rawData =~ /DEFINITION(.*)ACCESSION/s;
  $gbRecords{DEF} = "$1";
  #print "DEF is $1\n";
  #print "gbRecords{DEF} is $gbRecords{DEF} \n";

  $gbRecords{URL} = "$genbankFile";
  #print "gbRecords{URL} is $gbRecords{URL} \n";
  #print "URL is $i\n";

  $rawData =~ /ACCESSION(.*)VERSION/s;
  $gbRecords{ACC} = "$1";
  #print "DEF is $1\n";
  #print "gbRecords{ACC} is $gbRecords{ACC} \n";

  #$sth = $dbh->prepare($sqlInsertStatement);

  $sqlInsertStatement = qq(INSERT INTO $tableName (ID,URL,ACC,LOCUS,DEF,ORIGIN)
    VALUES(
    "$gbRecords{ID}",
    "$gbRecords{URL}",
    "$gbRecords{ACC}",
    "$gbRecords{LOCUS}",
    "$gbRecords{DEF}",
    "$gbRecords{ORIGIN}"
    ));


    $dbh->do($sqlInsertStatement) or die $DBI::errstr;
    print "Records successfully inserted \n";



}

$dbh->disconnect( );
