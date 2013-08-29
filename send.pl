#!/usr/bin/perl
use strict;


my $file_from = $ARGV[0];
my $file_to = $ARGV[1];
my $file_body = $ARGV[2];

my $continue = 1;
my $email_list = ();

my $from = ();
my $to = ();
my $to_name = ();
my $subject = ();
my $body = ();

#-------------Reading file from---------------------------------
sub name_from($) {
	open (FH, "<", shift)  or die ("Can't open file from: $!");
	
		while (<FH>) {
			if(/\w+\.\w+\@livenation.com/i)
			{
				$from = $_; 
				last;
			}
		}
		$from =~ s/\s+//g;

	close(FH);

	if(!defined($from))
	{
		die 'Dont have "from" email' . "\n";
	}
}
#-----------------------------------------------------------------

#-------------Reading file with emails----------------------------
sub name_to($) {
	open (FH, "<", shift) or die ("Can't open email list file: $!");

		while (<FH>) {
			if(/\w+\.\w+\@livenation.com/)
			{
				$to = $_; 
				last;
			}
		}
		$to =~ s/\s+//g;


		if(!defined($to))
		{

			close(FH);
			if($continue == 0)
			{
				die ("Email list is empty: $!");
			}
			&replace_files();
			$continue = 0;
			&name_to($file_to);
		}

		$continue = 1;

		while (<FH>)
		{
			$email_list .= $_;
		}

		$to =~ m/(\w+)\.(\w+)/;
		$to_name = $1;
	close(FH);


	&rewrite_email_remaining_list();
}
#------------------------------------------------------------------

#-------------Reading file with message body template-------------
sub read_template($) {
	open (FH, "<", shift) or die ("Can't open template file: $!");

	$subject = <FH>;
	$subject =~ s/\s*<Subject>\s*//;
	while (<FH>) {
		$body .= $_;
	}

	close(FH);

	if(!defined($body))
	{
		die 'Dont have "body" template' . "\n";
	}
}
#------------------------------------------------------------------

#--------------Sending mail----------------------------------------
sub send_email($) {
	$body =~ s/<name>/$to_name/;

	# open (SND, "|/usr/sbin/sendmail -f $from $to");

	# 	print SND "From: $from\n";
	# 	print SND "To: $to\n";
	# 	print SND "Subject: $subject\n";
	# 	print SND "\n";
	# 	print SND "$body\n";

	# close(SND);

	print "\n";
	print "From: $from\n";
	print "To: $to\n";
	print "Subject: $subject\n";
	print "\n";
	print "$body\n";

	print "\n";

	&write_sended_list();
}
#------------------------------------------------------------------

sub rewrite_email_remaining_list {

	open (FH, ">", $file_to) or die ("Can't write \"to send\" file: $!");
		print FH $email_list;
	close (FH);
}

sub write_sended_list {
	open (FH, ">>", "sended.txt") or die ("Can't append file: $!");
		print FH $to . "\n";
	close (FH);
}

sub replace_files {
	unlink ($file_to) or die ("Can't delete file: $!");
	rename "sended.txt", $file_to or die ("Can't replace files: $!");
}


&name_from($file_from);
&name_to($file_to);
&read_template($file_body);
&send_email();
