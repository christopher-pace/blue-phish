#! /usr/bin/perl
# Blue Phish - Automagically report IP addresses, hostnames, and accounts used in phishing attacks.
# Edit the variables below to your values, or obviously nothing will happen.
use Email::Send::SMTP::Gmail;
$your_email = ''; # Your email address
$imap_user = ''; # Incoming IMAP username
$imap_password = ''; # Fill this in to save it (NOT RECOMMENDED TO SAVE CREDS IN A PERL SCRIPT), or be prompted every time you start up the script for the password (the recommended way).
$imap_server = 'outlook.office.com'; # Set this to your incoming IMAP server, I recommend Outlook/Hotmail.
$smtp_user = ''; # Outgoing SMTP user
$smtp_password = ''; # Fill this in to save it (NOT RECOMMENDED TO SAVE CREDS IN A PERL SCRIPT), or be prompted every time you start up the script for the password (the recommended way).
$smtp_server = 'smtp.gmail.com'; # Outgoing mail server, I recommend Gmail.
$interval = '300'; # Interval to check for new phishing emails, in seconds.
$download = './download'; # Directory to temporarily download emails to.  Defaults to creating a "download" directory in the current working directory.
$attachment_downloader = `which attachment-downloader`; # Requires attachment downloader (pip install attachment-downloader to install).
chomp ($attachment_downloader);
# ~~-- Startup - Get Passwords and such --~~
print ("Welcome to Blue Phish - The Automagic Phishing Email Reporting Tool.\n");
print ("by: Christopher Pace\n\n\n");
if ($imap_password eq "")
{
print ("Thank you for not hard-coding passwords.  Please enter the incoming IMAP password now.\n");
$imap_password = <>;
chomp ($imap_password);
}
if ($smtp_password eq "")
{
print ("Thank you for not hard-coding passwords.  Please enter the outgoing SMTP password now.\n");
$smtp_password = <>;
chomp ($smtp_password);
}
if ($attachment_downloader eq "")
{
print ("FATAL ERROR: attachment-downloader not found.  Please install with \"pip install attachment-downloader\".\n");
die();
}
sleep (2); # Done with startup, sleep for 2 seconds then begin.

while () # This is our main program, loop forever until Control+C
{
print ("\n\nContacting IMAP server now, and downloading messages.\n");
if (system ("$attachment_downloader --host $imap_server --username $imap_user --password $imap_password --delete --output $download --imap-folder=INBOX --filename-template=\"\{\{date\}\}\""))
{
print ("Contacting IMAP server failed.\n\n");
}
else
{
print ("Logged into IMAP server and downloaded any new messages.\n");
}
@messages = `file $download\/* | grep \"RFC 822\"|cut -f 1-4 -d \:`; # Find the .eml files
chomp (@messages);
foreach my $email (@messages)
{
	#chomp ($email); # Shouldn't need this.
$from_sender = `cat \"$email\" | grep \"sender IP\"`; # $from_sender contains both SPF and IP.
print ("\n$from_sender\n"); # Debugging
$sender_ip = $from_sender; # Preserve $from_sender, we'll need that for the SPF stuff.
$sender_ip =~ s/[^0-9.]+//g;  # Grabs just an IP address, everything else in that line is alpha.
print ("IP from is $sender_ip\n");
@ip_abuse = `whois $sender_ip |grep abuse|grep \@ | awk '{print \$NF}'`; # Grab the abuse address for IP from whois
#@ip_abuse = s/[^0-9A-Za-z._-]+//g; # Shouldn't need this.
print ("\n@ip_abuse\n"); # Debugging
if (@ip_abuse eq "")
{
	print ("No abuse email results found for IP\n"); # We could do more later to try to find the abuse email address.
}
else{
foreach my $email_ip (@ip_abuse)
{
	print ("Emailing $email_ip\n"); # Debugging or Logging
	$message = "Abuse from $sender_ip \nWe received a phishing attack in our organization from an address you are listed as the abuse contact.  The original email is attached in plaintext format.  If you wish to view it in its original format, rename it to .eml.  Please investigate this issue, and reply to $your_email with any questions or comments.  Thank you for your assistance.";
	send_email($email_ip,$sender_ip,$message,$email);
}
}

# Include other test/reports here, like SPF.
# SPF from $from_sender
$spf = `echo \"$from_sender\" | cut -f 2 -d '='`;
$spf = `echo \"$spf\" | cut -f 1 -d \"\ \"`;
chomp ($spf);
if ($spf =~ "pass" || $spf =~ "none")
{
print ("SPF result is $spf !  Sending an abuse report to the sending domain!\n");
$email_from = `cat \"$email\" | grep From | grep \\@ | cut -f 2 -d \\< | cut -f 1 -d \\>`;
chomp ($email_from);
@domain_from = split('@', $email_from);
print ("Domain is @domain_from[1]\n");
@whois_domain = `whois @domain_from[1] |grep abuse|grep \@ | awk '{print \$NF}'`;
print ("Sending abuse reports to @whois_domain");


if (@whois_domain eq "")
{
        print ("No abuse email results found for the domain.\n"); # We could do more later to try to find the abuse email address.
}
else{
foreach my $email_domain (@whois_domain)
{
        print ("Emailing $email_domain\n"); # Debugging or Logging
        $message = "Abuse from @domain_from[1] \nWe received a phishing attack in our organization from a domain you are listed as the abuse contact.  The original email is attached in plaintext format.  If you wish to view it in its original format, rename it to .eml.  Please investigate this issue, and reply to $your_email with any questions or comments.  Thank you for your assistance.";
        send_email($email_domain,@domain_from[1],$message,$email);
}



}
}
else
{
	print ("Not sending an abuse report to the domain, as SPF did not pass.\n");
}
# Delete email, as we're done with it, now.
print ("Deleting email $email");
unlink ($email);
}
sleep ($interval); # Loop back to the beginning of this while loop once interval is over.
}

sub send_email
{
my ($dest_email,$offender,$message,$attachment) = @_;
$to = $dest_email;
chomp ($to);
$cc = $your_email;
$from = $smtp_user;
$subject = "Abuse report for $offender";
$message = $message;
my ($mail,$error)=Email::Send::SMTP::Gmail->new( -smtp=>$smtp_server,
                                                 -login=>$smtp_user,
                                                 -pass=>$smtp_password);
 
print "session error: $error" unless ($mail!=-1);
 
$mail->send(-to=>$to, -cc=>$your_email, -subject=>$subject, -body=>$message,
            -attachments=>$attachment);
 
$mail->bye;


print "Email Sent to $to\n";
return();
}
