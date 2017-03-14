# author : Delvin So
# Purpose : given an existing hash of arrays structure and the following file (format: author#quote), load the file into the hash of arrays
# structure and transfers the data from the hash of arrays structure into a table.

# author.dat - 

# einstein#whoever is careless with the truth in small matters cannot be trusted with important matters
# huxley#all truth, in the long run, is only common sense clarified
# einstein#insanity:doing the same thing over and over again and expecting different results
# socrates#wisdom begins in wonder
# holmes#insanity is often the logic of an accurate mind overtaxed
# einstein#peace cannot be kept by force; it can only be achieved by understanding
# huxley#logical consequences are the scarecrows of fools and the beacons of wise men
# socrates#once made equal to man, woman becomes his superior
# holmes#it is the province of knowledge to speak, and it is the privilege of wisdom to listen



#/usr/bin/perl
use strict;
use warnings;
use DBI;

#initializing variables to connect to SQLite
my $databaseName = "wisdom.db";
my $databaseConnect = "dbi:SQLite:dbname=$databaseName";
my $userName = "";
my $password = $userName;
my $dbh = DBI->connect($databaseConnect, $userName, $password, { RaiseError => 1 }) or die $DBI::errstr;
my $tableName = "QUOTES";
my $sqlInsertStatement;

my $tableCreator = 'CREATE TABLE "QUOTES" (
id INTEGER PRIMARY KEY AUTOINCREMENT,
author VARCHAR(100),
quote  VARCHAR(500)
);';
$dbh->do("DROP table IF exists $tableName");
$dbh->do($tableCreator) or die $DBI::errstr;


my %hashOfArrays = (
		      flintstones        => [ "fred", "barney" ],
		      jetsons            => [ "george", "jane", "elroy" ],
		      simpsons           => [ "homer", "marge", "bart" ],
		   );
my $file = 'author.dat';


open my $fh, '<', $file or die "Cannot open $file: $!";
while ( my $line = <$fh> ) {
	my @tempArray = split('#', $line); #splitting the line on # and storing it into an array
	push @{$hashOfArrays{$tempArray[0]}}, $tempArray[1];
	#print "Quote:", @{$hashOfArrays{$tempArray[0]}}, "\n";
}
close($fh);

foreach my $keys (keys %hashOfArrays) {
	print "Author : $keys \n";
	foreach my $quote ( @{$hashOfArrays{$keys}} ) {
		my $sqlInsertStatement = qq(INSERT INTO $tableName (author, quote) VALUES(
		"$keys",
		"$quote"
		));
		print "Quote : $quote \n";
		$dbh->do($sqlInsertStatement) or die $DBI::errstr;
		print "Records successfully inserted \n";
	}
}

# Output

# sqlite> .open wisdom.db
# sqlite> .mode column 
# sqlite> .headers on #turns on headers 
# sqlite> .width 0 0 100 #alters width of column so quote fits on screen
# sqlite> select * from quotes;
# id          author       quote
# ----------  -----------  ----------------------------------------------------------------------------------------------------
# 1           flintstones  fred
# 2           flintstones  barney
# 3           huxley       all truth, in the long run, is only common sense clarified
#
# 4           huxley       logical consequences are the scarecrows of fools and the beacons of wise men
#
# 5           jetsons      george
# 6           jetsons      jane
# 7           jetsons      elroy
# 8           simpsons     homer
# 9           simpsons     marge
# 10          simpsons     bart
# 11          holmes       insanity is often the logic of an accurate mind overtaxed
#
# 12          holmes       it is the province of knowledge to speak, and it is the privilege of wisdom to listen
#
# 13          einstein     whoever is careless with the truth in small matters cannot be trusted with important matters
#
# 14          einstein     insanity:doing the same thing over and over again and expecting different results
#
# 15          einstein     peace cannot be kept by force; it can only be achieved by understanding
#
# 16          socrates     wisdom begins in wonder
#
# 17          socrates     once made equal to man, woman becomes his superior
