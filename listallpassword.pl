#!/usr/bin/env perl
#That script has to run on the vault server itself please run it under your user
#Please make sure that vault_addr and vault_namespace are correct

 my $setenv =
     "VAULT_ADDR=https://active.vault.service.consul:8200 && ".
     "VAULT_NAMESPACE=PAR &&";
 my $path = $ARGV[0];
 if ($path!~/\/$/) {
     $path="$path/";
 }
 push @list, getData($path);

 sub getData {
     my $path=shift;
     my @ret=();
     my $command="$setenv vault kv list -tls-skip-verify $path | tail -n+3 ";
     my @lines = `$command`;
     chomp @lines;
     foreach my $line (@lines) {
         if ($line=~/\/$/) {
             my @result = getData($path.$line);
             if (scalar(@result)>0) {
                 # Find deeper results
                 push @ret, @result;
             } else {
                 # empty final dir, no values
                 push @ret, { path => $path.$line };

             }
         } else {
             # Found a key!
             print STDERR " $path$paths$line\n";
        }
     }
}
