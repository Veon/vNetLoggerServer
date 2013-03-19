#!/usr/bin/perl

package Proc; # Объявляем свой пакет

use strict; # Так в книжке написано ;)
use base qw(Net::Server::Fork); # Наследуем
use Logger::Logger;
use Error;
use XML::Simple;
use Data::Dumper;
use Module::Runtime qw(
                $top_module_spec_rx $sub_module_spec_rx
                is_module_spec check_module_spec
                compose_module_name
        );

sub default_values {
return {
        port => 9999,
        };
}

sub process_request {
	my $self = shift;
        my $prop = $self->{'server'};
	my $xs = XML::Simple->new();
	my $debug_file = $self->{server}->{log_file};
	my $logger = new Logger::Logger ( $debug_file, 1 ) or die "Can't create object: Logger::Logger::Error";

        if (!$prop->{udp_true}) {
		$logger->debug_message("Not UDP package!"); exit;
        }

	(my $name, my $path, my $log_text) = split(/:::/, $self->{'server'}->{udp_data}); 

	if ( ! -d $path ) {
		mkdir $path;
	}

        open(LOG_FILE, ">>$path/$name");
	print LOG_FILE $log_text;
	close(LOG_FILE);
	if ($prop->{'udp_data'} =~ /dump/) {
		local $Data::Dumper::Sortkeys = 1;
		$prop->{'client'}->send(Data::Dumper::Dumper($self), 0);
	} else {
		$prop->{'client'}->send("You said \"$prop->{udp_data}\"", 0);
	}

	return;
	
}

1;
