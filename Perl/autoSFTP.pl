#! /usr/bin/perl
use strict;
#use warnings;
use Net::SFTP::Foreign;
use POSIX;
use Data::Dumper;

my $starttime = time();
while(){
	my $newtime = time();
	if ($newtime > $starttime){

		my %downloadlistRemote = ();
		my %scriptlistRemote = ();
        my %downloadlistLocal = ();
        my %scriptlistLocal = ();
		my %runscripts = ();
		my %downfiles = ();
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		my $now_string = localtime;
		print STDERR "$now_string New round.\nNow beginning download...\n";
		&download ('/var/www/html/~/data/upload/','/var/www/html/~/data/upload/',\%downloadlistRemote);
        &download ('/var/www/html/~/data/scriptTem/','/var/www/html/~/data/runscript/',\%scriptlistRemote);
        print STDERR "Finish download from remote server.\n";

        foreach my $key (keys %scriptlistRemote){
           if (not exists $downloadlistRemote{$key}) {
               delete $scriptlistRemote{$key};
		   }
		}
        opendir UPLOAD, '/var/www/html/~/data/upload/' || die "open script dir error: $!";
        my @files = readdir UPLOAD;
        foreach my $f (@files){
          if ($f =~ /^(\d+)\.upload/ ){
            my $id=$1;
            $downloadlistLocal{$id}++;
          }
        }
        opendir SCRIPT, '/var/www/html/~/data/scriptTem/' || die "open script dir error: $!";
        my @scriptstem = readdir SCRIPT;
        foreach my $f (@scriptstem){
          if ($f =~ /^(\d+)\./ ){
            my $id=$1;
            system "mv /var/www/html/~/data/scriptTem/$f /var/www/html/~/data/runscript/";
            my $mtime = (stat "/var/www/html/~/data/runscript/$f")[9];
			$scriptlistLocal{$id} = $mtime;
          }
        }

        print STDERR "Finish download from local server.\n";

        %runscripts = (%scriptlistRemote, %scriptlistLocal);
		%downfiles = (%downloadlistRemote, %downloadlistLocal);

        print Dumper(\%runscripts);
        foreach my $jobid (sort {$runscripts{$a}<=>$runscripts{$b}} keys %runscripts){
            if (exists $downfiles{$jobid}){
                print STDERR "RUN $jobid.pl\n";
				print "sh /var/www/html/~/data/runscript/$jobid.pl\n";
                system "sh /var/www/html/~/data/runscript/$jobid.pl";
				print STDERR "Finish running\n";
				
				my $dir= "/var/www/html/~/data/download/$jobid";
				if (-d $dir){
					chdir "$dir";
					opendir IN,'.' or die $!;
					my @filelist = readdir (IN);
					foreach my $f (@filelist){
						if ($f !~ /^\.+/){
							print STDERR "Upload $jobid $f\n";
							&upload_tar ( $f,"/var/www/html/mr2_dev/data/download/$jobid");
						}
					}
					closedir IN;
				}				
            }
			
        }

		$starttime = time();
		$starttime += 360;
		print STDERR "This round is finish.\n";
	}
}

sub download
{ 
	my $sftp = Net::SFTP::Foreign->new('', user => '', password => '' , port =>  ,timeout => 1800);

        if ($sftp->error) {
           print ("Connect Failed : ".$sftp->error);
		   return;
        }
		if (not $sftp) {
		   print ("Error: No Connection:$@");
		   return;
		}

	my $path = shift;
	my $fpath = shift;
	my $list = shift;
	$sftp->setcwd("$path");
	my $file= $sftp->ls('.');
	foreach my $k ( @$file){
		if ($k->{'filename'} =~ /^(\d+)\./ ){
			my $id=$1;
			my $f=$fpath.$k->{'filename'};
			
			$sftp->get($k->{'filename'},$f);
            my $mtime = (stat $f)[9]; 
			$$list{$id} = $mtime;	
		}
		if ($k->{'filename'} =~ /^(\d+)\./ and $k->{'filename'} !~ /^(\d+)\.pl/){
			$sftp->remove($k->{'filename'});
		}
		if ($k->{'filename'} =~ /^(\d+)\.pl/){
            $sftp->rename($k->{'filename'},"ok".$k->{'filename'});
        }
	}
	undef $sftp;
}

sub upload_tar
{
	my $upfile= shift;
	my $crdir =shift;
	my $sftp = Net::SFTP::Foreign->new('', user => '', password => '' , port =>  , timeout => 1800) or die "Cannot find ftp " ;
	
	$sftp->setcwd($crdir);
	$sftp->put($upfile,$upfile) ;
	undef $sftp;

}

