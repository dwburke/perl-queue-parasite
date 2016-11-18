
use Test::Spec; # automatically turns on strict and warnings
use FindBin;
use JSON;
use lib "$FindBin::Bin/../lib";
use HTTP::Response;

use Queue::Parasite::Message;


my $webhook_message_1 = {
    type => 'webhook',
    webhook => 'http://localhost/blah?foo=bar',
};

my $data1 = { 
    body => to_json($webhook_message_1),
};


my $webhook_message_2 = {
    type => 'webhook',
    webhook => {
        url => 'http://localhost/blah?baz=gaz',
        pass => 'http://localhost/pass',
        fail => 'http://localhost/fail',
    },
};

my $data2 = { 
    body => to_json($webhook_message_2),
};


describe "Queue::Parasite::Message" => sub {

    describe "webhook scalar" => sub {
        my $msg;

        before each => sub {
            $msg = Queue::Parasite::Message->new(data => $data1);
        };

        it "url is set" => sub {
            ok($msg->url eq 'http://localhost/blah?foo=bar');
        };

        it "calls home once (url)" => sub {
            my $expect = LWP::UserAgent->expects('get')->returns( HTTP::Response->new(200) )->once;
            $msg->process;
            ok($expect->verify);
        };
    };


    describe "webhook hash" => sub {
        my $msg;

        before each => sub {
            $msg = Queue::Parasite::Message->new(data => $data2);
        };

        it "url is set" => sub {
            ok($msg->url eq 'http://localhost/blah?baz=gaz');
        };

        it "pass is set" => sub {
            ok($msg->pass eq 'http://localhost/pass');
        };

        it "fail is set" => sub {
            ok($msg->fail eq 'http://localhost/fail');
        };

        it "calls home twice (url + pass)" => sub {
            my $expect = LWP::UserAgent->expects('get')->returns( HTTP::Response->new(200) )->exactly(2);
            $msg->process;
            ok($expect->verify);
        };

        # failure testing

    };

};

runtests unless caller;

