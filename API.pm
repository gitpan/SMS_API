package SMS::API;

#################################################################################
#
#
#             GOYALI.COM
#
#################################################################################
#NOTE: Distributing this script is permitted but requires a licence. Visit www.goyali.com/contact.htm for requesting
#that . Provide the reason for distributing the script ie. for which application do you want to use the cript. You will be responded within hours.
#Disclaimer: This program is distributed as it is and the author or goyali.com does not claim any responsibilities for the successful operation of this program or that we are not sure that it will or can cause any abnormality in your computer. However during our testing no such problem occured.
#For a detailed policy visit www.goyali.com/policy.htm
#
#
#This script is Prepared by ,
#Abhsihek jain
#CEO and Chief Programmer
#Goyali.com
#

require 5.000;
require Exporter;
use strict;
use warnings;

use Carp;

our @ISA = qw(Exporter);
our @EXPORT = qw(&send_sms_email &sms_status &sms_send);


our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '2.01';


sub send_sms_email{
        my ($user,$password,$to,$sender,$message,$email)=($_[0],$_[1],$_[2],$_[3],$_[4],$_[5]);
        my $mailprog = "/usr/sbin/sendmail";
        open (MAIL, "|$mailprog -oi -t") or die "Can't open pipe to $mailprog : \n";
        print MAIL "To: smsmessaging\@goyali.com\n";
        if($email &&($email =~ /\@/)){ print MAIL "From: $email\n";}else{print MAIL "From: webmaster\@goyali.com\n";}
        print MAIL "Subject: SMS Gateway for $user\n";
        print MAIL "X-Loop: project\@ejain.com\n";
        print MAIL "User=$user\nPASSWORD=$password\nTO=$to\nSENDER=$sender\nREPLY=$email\nMESSAGE=$message";
        close MAIL;
}

sub sms_status{
     my ($user,$password,$messageid_id)=($_[0],$_[1],$_[2]);
#     my ($user,$password,$messageid_id)=@_;
    if(!$user||!$password||!$messageid_id){return 0;}
     my $xml_send1=<<EOF;
<?xml version="1.0" encoding="ISO-8859-1"?>
<RequestStatus User='$user' Password='$password'>
<messageId ID='$messageid_id'/>
</RequestStatus>
EOF
  use HTTP::Request::Common qw(POST);
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  my $post_name='http://www.goyali.com/cgi-bin/services/sms_gateway/status.cgi';
  my $req = POST "$post_name",
                    [
                        Data => "$xml_send1",
                        action => "status"  ,
                        submit => "send"
                    ];
     my $res=$ua->request($req);
  my $xml_ret=$res->content;
#  print $xml_ret;
   if ($res->is_success) {
  } else {
      return '0';
  }


    my $config = XMLin($xml_ret);
  my $error_code=$config->{'error'}->{'code'};
  my $delivery_status_code=$config->{'delivery-status'}->{'code'};
  if($error_code){return 0;}
  elsif($delivery_status_code){return "$delivery_status_code";}
  else {return '0';}
}

sub sms_send{
     my ($user,$password,$to,$message,$from)=($_[0],$_[1],$_[2],$_[3],$_[4]);
    if(!$user||!$password||!$to||!$message||!$from){return 0;}
    if(!$from){
      $from='GOYALI.COM';
    }
 $message=substr $message,0,159;
  $message=~ s/\&/\&amp;/gi;
   $message=~ s/\</\&lt;/gi;
 $message=~ s/\'/\&apos;/gi;

  use HTTP::Request::Common qw(POST);
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  my $xml_send1=<<EOF;
<?xml version="1.0" encoding="ISO-8859-1"?>
<Messaging User='$user' Password='$password'>
<Sender PutSender='$from'/>
<Message Text='$message'/>
<Receiver PutReceiver='$to'/>
</Messaging>
EOF
  my $post_name='http://www.goyali.com/cgi-bin/services/sms_gateway/send.cgi';
  my $req = POST "$post_name",
                    [
                        Data => "$xml_send1",
                        action => "send"  ,
                        submit => "send"
                    ];
  my $res=$ua->request($req);
  my $xml_ret=$res->content;
   if ($res->is_success) {
  } else {
      return '0';
  }
  use XML::Simple;
  my $config = eval { XMLin($xml_ret) };
  return '0' if($@);
  my $ok=$config->{completelyOk};
  my $incoming_time=$config->{incomingTime};
  my $message_id_ok=$config->{MessageAck}->{'messageId'};
  my $error_text=$config->{Error}->{'errorText'};
  my $error_code_send=$config->{Error}->{'errorCode'};
  my $message_id_error=$config->{Error}->{'messageID'};
  if($ok eq 'no' || !$ok){
    return '0';
  }else{
     return "$message_id_ok";
  }
  return '0';
}

1;

__END__


=head1 NAME

SMS::API - A module to send SMS using the goyali.com servers

=head1 SYNOPSIS

  use SMS::API;
  $message_id=sms_send("$user","$password","$to","$message","$from");

  $sent_status=sms_status("$user","$password","$message_id");

=head1 DESCRIPTION

This is a module for sending the SMS by integrating with the servers of http://www.goyali.com.

For a solution of directly sending the SMS via internet or through SMS visit http://www.goyali.com

In case of any problem whatsoever please do not hesitate to contact http://www.goyali.com/contact.htm .We have an excellent team of customer support and you will be responded in hours.

NOTE: You first need to register at http://www.goyali.com/contact.htm (visit the URL and request a sms gateway account. You will given one within hours)for using this module. On registering you will be given a user id and password and some free test credits. You can use the credits to send the SMS.

NOTE: We are very serious about this module and any errors performed are requested to be reported at http://www.goyali.com/contact.htm

At the moment these methods are implemented:

=over 4

=item C<sms_send("$user","$password","$to","$message","$from")>

This method send an SMS. The parameters sent are :
$user , $password = The user name and Password given to you at the time of signup.
$message= The message you wish to send.
$from= If your account supports dynamic sender id then this parameter will tell what will be the from id as seen by the mobile.

On successful sending the SMS the function returns the unique message id which can be used to track the delivery status of the SMS otherwise it will return 0.

=item C<sms_status("$user","$password","$message_id")>

This method gives the status of the SMS ie. whether it has been sent or not. The parameters sent are :
$user , $password = The user name and Password given to you at the time of signup.
$message_id= The message id whose status you want to determine.

The function returns the status of message ie. 1 if message has been received by the mobile , 0 if it has not been delivered yet ie. Failure or Retrying.

=back

=head2 EXPORT

send_sms_email , sms_send , sms_status .


=head1 AUTHOR

Abhishek jain<lt>goyali@cpan.org<gt>

=head1 SEE ALSO

http://www.goyali.com


=cut
