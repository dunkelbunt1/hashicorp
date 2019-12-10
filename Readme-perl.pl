On the vault server in the terminal do the following things:

vim perl.pl
------------------------------Copy-that-part-into-the-file---------------------------
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
------------------------------Copy-that-part-into-the-file---------------------------
:x!

next step is to run the following command:
----------------------------------------------------------------------------------------------
export VAULT_NAMESAPCE=PAR
vault login (INSERT_ROOT_TOKEN)
vault secrets list | awk '{print $1}' > collection
vim accounts.sh
------------------------------Copy-that-part-into-the-file---------------------------

for i in  $(cat collection) ; do
/usr/bin/perl perl.pl $i &> accounts.csv;
done
------------------------------Copy-that-part-into-the-file---------------------------
:x!

Now you need to make both scripts runnable
chmod +x perl.pl
chmod +x accounts.sh

run the script with ./accounts.sh

If you would just like to check one collection you can run the script the following way:
perl perl.pl gts_test_infra
(gts_test_infra in that case is the collection)

That will produce an output file called accounts.csv

This file needs to be a bit filtered  afterwards (I am sorry for that but it also writes errors)
Let me know what you think or if you see any errors.
