# blue-phish
Blue Phish - Automated Abuse Reporting for Phishing Emails
By: Christopher Pace (Pace)

TL;DR:

--IMPORTANT: EDIT THE SCRIPT VARIABLES BEFORE RUNNING--

Blue Phish is a script that monitors an abuse mailbox for emails forwarded from you to the script.  Once they arrive (as .eml attachments), they are parsed for the sending IP address and domain (unless SPF fails), and then the messages are reported to the IP address abuse and domain abuse email addresses.  This enables system administrators to automate the reporting of abuse so that an attacker will continue to spend more of their time acquiring infrastructure, and less time attacking yours.  Download the Perl script, install the required dependencies, edit the configuration values for your environment, and let it run 24/7, checking for new emails to report every 10 minutes by default.

The Long Story:

Blue Phish was created as a way for Blue Teamers, or network defenders, to have a way to automatically submit abuse reports to the abuse email addresses responsible for a domain or IP address that sent a phishing email.  This is an important, yet often overlooked, portion of the response process in  a phishing attack.  In something that takes less than 10 seconds, you can cost attackers literally hours worth of work.

--Why is Reporting Malicious IP Addresses and Domains Going to Hurt Attackers?--

Ask any threat actor what the biggest pain when launching a phishing attack that uses typosquatting or other “advanced” tactics is.  You might think that sending phishing emails requires ‘1337 HTML Skillz’, or that searching open source intelligence information for vulnerable executives within an organization might be the biggest pains.  When a  threat actor wants to launch a phishing attack, they’re going to do some research.  They’re going search for victims, cross-reference that data with leaked information to find victims that are prone to breaches, and maybe even parse that data to select only the victims in a specific department within an organization (accounting, management, human resources, etc).  All that sounds like a huge task, but it isn’t.  That stuff can be easily automated.  So, what part of an attack takes up the most time?  It’s the infrastructure.

If you’re reading this, you’ve probably set up a domain before.  It’s no big deal.  You log into your preferred domain registrar, buy whatever you want, and then you forward it off to your servers – easy-peasy!.  Literally millions of people on the planet have done this.  However, you might not have done this using “less than legal methods”.  This is the painful part of being a “bad guy”.

If you’re a threat actor that’s worried about being caught, the first thing you want to do is get a stolen credit card or prepaid card that you bought with cash.  In the latter example, you have to actually walk to a store and buy the card (and then wait a few weeks before using it).  In the former example, you’ll search the “Dark Web” for stolen credit card vendors before buying several cards (you’ll be ripped off with at least the first few), and eventually you MIGHT get a valid credit card.  You might think the pain is over with getting a valid card (prepaid, or “otherwise”), but the pain is just beginning.  Now you need a registrar.

Go ahead and search to find a domain registrar that doesn’t require MFA for account creation.  I’ll wait.  Did it take you an hour to find a seedy registrar that doesn’t require MFA?  Let’s not forget, you’re using some high latency Tor browser connection to search for “domain registrars that don’t want my cell phone”.  Nearly every domain registrar wants some sort of way to send you a text message in order to prove that you aren’t a bot.  So, how does a “bad guy” get around this problem?

Maybe you’ve  been down this road before – you know that you need an SMS relay service to sign up for a new account at a domain registrar that you’ll dedicate for this attack.  You’ve identified a good anonymous SMS relay, got your stolen/prepaid card, and you’re ready to register a domain in your phishing attack.  Good for you.  Now, I hope you’re familiar with MX records and have a mail server handy.  You’ll need it.

What’s that?  You plan on using a free tier on Gmail to launch your attacks?  You’d better have that SMS relay available.  Oh wait, Gmail blocks most of the SMS relay services.  You try again, and again.  Finally, you get your hosting configured, figured out how MX records work, and you’ve finished setting up your mail server.  You should probably configure SPF while you’re at it – it will only take another 5 minutes or so.  At this point, you’ve at least spent an hour setting up your phishing domain. 

Once you’ve got your phishing domain, you need a server to send those phishing emails from.  Attackers will typically use a compromised host for this, which they usually pay money for.  After all, who has time to do all that earlier work, and still have spare time to compromise some crappy web server to send phishing emails?  Still, acquiring a compromised server takes time too, although if you buy compromised hosts in bulk you might save some time there.  Let’s say that it takes a total of 10 minutes per host if you bulk purchase multiple  servers from a botnet.  That’s another 10 minutes in addition to the hour hour we’ve spent already….and we haven’t even sent a phishing email yet!

--How Much of a Difference is One Abuse Email Going to Make?--

For those of you (definitely not me) who have ever pirated a movie and been reported, you might wonder what difference a single abuse report will make.  After all, your ISP keeps sending you emails about all the Rick and Morty episodes you’ve downloaded, and they still haven’t disconnected your internet.  There’s a big difference between a user on a consumer ISP downloading movies, and a web server hosted in a “professional” hosting provider sending malicious emails.  Web hosting companies are constantly fighting off Spamhaus and other spam/phishing reporting services – they want absolutely nothing to do with a suspicious host on their hosting platform.  So, they take action quickly to control the “bleeding” when a host is suspected of being compromised.

As for domain registrars, they also have a reputation (and a requirement) to investigate and take down malicious domains in a timely manner.  No one wants to be known as a shady registrar and anger the ICANN gods.  Further, no registrar wants any part of illegal business, since that $9.99 paid to register the domain will likely get reported as a malicious credit card transaction (remember, stolen credit cards are often used).

So yeah, there’s motivation on both the network and domain side of things to take down malicious hosts sending phishing emails.  All they need are reports, which happens so rarely.  I get it, I’ve been there myself.  You’re in the middle of an incident, and who has time to dig through whois records and send emails to third parties?  You’ve got accounts to lock out, passwords to reset, and bosses to send “lessons learned” reports to.  If only there was a way to automate that boring stuff...

--Blue Phish to the Rescue!--

Here’s where Blue Phish comes in.  All you have to do is save the original phishing email as a .eml file, attach that to a new email to the dedicated email address you want to use for gathering these reports, and hit send.  The script will download the new email within 10 minutes, search all downloaded emails for .eml attachments, and then proceed to send off those abuse reports to those that harbor your enemy.  It’s an easy way to bring pain to your adversary!

Now, there is a word of caution: it’s best to register a free Gmail or Hotmail account for this script.  Worst case scenario, you don’t read the fine print (this is for advanced phishing attacks only), and you report all the phishing emails you get.  Congratulations, you’ve probably just marked that address or domain as spam !  So, use this script for advanced attacks only, where you know that both the sending IP address and domain name the email originated from are both malicious (or that the sending domain failed SPF, which bypasses the domain abuse reporting).  Otherwise, you’re going to make a few people angry.  No one likes to receive an irrelevant or invalid abuse report.

--Conclusion--

If you’ve read all of this, congratulations!  Hopefully you have a better idea of why this script was written and why it’s important.  This script was tested using Hotmail as the incoming IMAP server and Gmail as the outgoing SMTP server.  Using separate accounts for analyzing the phishing emails and sending the abuse reports is important too, as the script will literally report based off of any .eml attachment sent to it.  That can lead to “abuse loops” if the registrar replies to your email address that is used for searching incoming phishing emails.  Any other email services other than Gmail or Hotmail may require some tweaking.  Feel free to alter the code to match your requirements.

By bringing as much pain to attackers as possible, we can make the world more dangerous and expensive for attackers.  The more infrastructure we bring down, the more pain we can cause our attackers, we make phishing less profitable and more dangerous.  Reporting is an absolute necessity – without reporting an attack, you’re encouraging malicious actors to continue attacks on your organization or others.
