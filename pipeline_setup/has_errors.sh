#!/bin/bash

#error.log is the bash stderr output from running cypress tests in a container 
#this script will parse that log and remove any known errors - NB. the cert errors constitute multiple lines in the log
#If there are any remainng errors these get published to the screen and will stop the build pipeline
#NOTE: ideally there should be a fix for the underlying errors

filename="error.log"

#remove known errors
sed -i "s/.*Generating browser application bundles.*//" $filename
sed -i "s/.*Browser application bundle generation complete.*//" $filename
sed -i "s/.*libva error: vaGetDriverNameByIndex() failed with unknown libva error.*//" $filename
sed -i "s/.*ERROR:sandbox_linux.cc(377)] InitializeSandbox() called with multiple threads in process gpu-process.*//" $filename
sed -i "s/.*ERROR:gpu_memory_buffer_support_x11.cc(44)] dri3 extension not supported.*//" $filename
#remove cert errors
sslerrors=($(grep -c "cert_verify_proc_builtin" error.log))
if [ $sslerrors -gt 0 ];
then
	echo "ignoring cert_verify_proc_builtin error $sslerrors times"
	sed -i "s/.*ERROR:cert_verify_proc_builtin.cc(681)] CertVerifyProcBuiltin.*//" $filename
	sed -i "s/.*Cypress Proxy Server Certificate.*//" $filename
	sed -i "s/.*ERROR: No matching issuer found.*//" $filename
fi

#remove all empty lines
sed -i '/^[[:space:]]*$/d' $filename

#count of remaining errors 
errorcount=($(wc -l $filename))

if [ $errorcount -gt 0 ];
then
	echo "found $errorcount errors in $filename"
	cat $filename
	exit 1;
else
    echo "No errors in $filename"
	exit 0;
fi
