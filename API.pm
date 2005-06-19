package SMS::API;

#################################################################################
#
#
#             SMS1.in Goyali.com webbee.biz eMailOnMove.com
#
#################################################################################
#NOTE: Distributing this script is permitted but requires a licence. Visit www.sms1.in/contact.html for requesting
#that . Provide the reason for distributing the script ie. for which application do you want to use the cript. You will be responded within hours.
#Disclaimer: This program is distributed as it is and the author or sms1.in does not claim any responsibilities for the successful operation of this program or that we are not sure that it will or can cause any abnormality in your computer. However during our testing no such problem occured.
#For a detailed policy visit www.sms1.in/policy.htm
#
#
#This script is Prepared by ,
#Abhsihek jain
#CEO and Chief Programmer
#SMS1.in
#
use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);


our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();
our $VERSION = '3.01';


# Preloaded methods go here.
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use XML::Simple;
my $ua = LWP::UserAgent->new;
sub new {
    my ($self);
    my $class = shift;
    my (%hash) = @_;
    $self = bless {
        'userName' => $hash{userName},
        'password' => $hash{password},
        'messageId'=> $hash{messageId},
        'messageText' => $hash{messageText},
        'from' =>$hash{from},
        'to' =>$hash{to},
         }, $class;
    return $self;
}

sub send{
  my $self = shift;
  if(!$self->{userName}||!$self->{password}||!$self->{to}||!$self->{messageText}){return 0;}
    if(!$self->{from}){
      $self->{from}='SMS1';
    }
 $self->{messageText}=substr $self->{messageText},0,159;
 $self->{messageText}=~ s/\&/\&amp;/gi;
 $self->{messageText}=~ s/\</\&lt;/gi;
 $self->{messageText}=~ s/\'/\&apos;/gi;

  use HTTP::Request::Common qw(POST);
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  my $xml_send1=<<EOF;
<?xml version="1.0" encoding="ISO-8859-1"?>
<Messaging User='$self->{userName}' Password='$self->{password}'>
<Sender PutSender='$self->{from}'/>
<Message Text='$self->{messageText}'/>
<Receiver PutReceiver='$self->{to}'/>
</Messaging>
EOF
  my $post_name='http://www.sms1.in/cgi-bin/services/sms/send.sms';
  my $req = POST "$post_name",
                    [
                        Data => "$xml_send1",
                        action => "send"  ,
                        submit => "send"
                    ];
  my $res=$ua->request($req);
  my $xml_ret=$res->content;
   unless ($res->is_success) {
      return '0';
  }

  my $config = eval { XMLin($xml_ret) };
  return '0' if($@);
  my $ok=$config->{completelyOk};
  my $incoming_time=$config->{incomingTime};
  my $message_id_ok=$config->{MessageAck}->{'messageId'};
  my $error_text=$config->{Error}->{'errorText'};
  my $error_code_send=$config->{Error}->{'errorCode'};
  my $message_id_error=$config->{Error}->{'messageID'};
  if($message_id_ok){
   return $message_id_ok;
   }else{
    return "0";
  }
  return '0';
}

sub status {
    my $self = shift;
    
    if(!$self->{userName}||!$self->{password}||!$self->{messageId}){
#      print "Sorry no userName or password or Message Id specified";
      return '0';
    }
     my $xml_send1=<<EOF;
<?xml version="1.0" encoding="ISO-8859-1"?>
<RequestStatus User='$self->{userName}' Password='$self->{password}'>
<messageId ID='$self->{messageId}'/>
</RequestStatus>
EOF
  my $post_name='http://www.sms1.in/cgi-bin/services/sms/status.sms';
  my $req = POST "$post_name",
                    [
                        Data => "$xml_send1",
                        action => "status"  ,
                        submit => "send"
                    ];
   my $res=$ua->request($req);
   my $xml_ret=$res->content;

   unless($res->is_success) {
      return '0';
  }


  my $config = XMLin($xml_ret);
  my $error_code=$config->{'error'}->{'code'};
  my $delivery_status_code=$config->{'delivery-status'}->{'code'};
  if($error_code){return 0;}
  elsif($delivery_status_code){return "$delivery_status_code";}
  else {return '0';}
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

SMS::API - A module to send SMS using the sms1.in servers

=head1 SYNOPSIS
  use XML::Simple;
  use SMS::API;
                        #To send SMS Replace with username and password and message text. You can get User name by visiting http://www.sms1.in
    my $sms = SMS::API->new(
    'userName' => "$user_name",
    'password' => "$password",
    'to' =>  "$to",      #Substitute by a valid International format mobile number to whom you wanted to send SMS. eg. 919811111111
    '$from' => "$from",  #Optional
    'messageText'=>"$message_text", #Max 160 characters Message.
      );
$send = $sms->send;

                  #To check the status of the messages sent;
    my $sms = SMS::API->new(
    'userName' => $userName,
    'password' => $password,
    'messageId'=>$messageId,
      );
    $status = $sms->status; #$status will be sent to 1 if message hacs been received



=head1 DESCRIPTION

This is a module for sending the SMS by integrating with the servers of http://www.sms1.in

For a solution of directly sending the SMS via internet or through SMS visit http://www.sms1.in
In case of any problem whatsoever please do not hesitate to contact http://www.sms1.in/contact.html .We have an excellent team of customer support and you will be responded in hours.

NOTE: You first need to register at http://www.sms1.in/signup.html (visit the URL and request a sms gateway account. You will given one within seconds and it is free)for using this module. On registering you will be given a user id and password and some free test credits. You can use the credits to send the SMS.

NOTE: We are very serious about this module and any errors performed are requested to be reported at http://www.sms1.in/contact.html

NOTE: This module has a dependency over XML::Simple and that must be installed to properly send the SMSes . It can be optained easily from cpan.

At the moment these methods are implemented:

=over 4

=item C<new>
A constructor

=item C<send>

This method send an SMS. The parameters sent are :
userName , password = The user name and Password given to you at the time of signup.
messageText = The message you wish to send.
from = If your account supports dynamic sender id then this parameter will tell what will be the from id as seen by the mobile.
to = The mobile number whom you wish to send SMS to in international  format eg. 919811111111 .

On successful sending the SMS the function returns the unique message id which can be used to track the delivery status of the SMS otherwise it will return 0.

=item C<status>

This method gives the status of the SMS ie. whether it has been sent or not. The parameters sent are :

The function returns the status of message ie. 1 if message has been received by the mobile , 0 if it has not been delivered yet ie. Failure or Retrying.

You can also visit the SMS1.in to check the status by logging on to your account.

=back


=head1 AUTHOR

<Abhishek jain>
goyali at cpan.org

=head1 SEE ALSO

http://www.sms1.in


=cut
