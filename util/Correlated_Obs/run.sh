#!/bin/sh
#date of first radstat file
bdate=2014040500
#date of last radstat file
edate=2014040600
#instrument name, as it would appear in the title of a diag file
instr=airs_aqua
#location of radstat file
exp=prCtl
diagdir=/da/noscrub/${USER}/archive/${exp}
#working directory
wrkdir=/stmpp1/${USER}/desroziers_${exp}_${bdate}
#location the covariance matrix is saved to
savdir=$diagdir
#type- 0 for all, 1 for sea, 2 for land, 3 for ice, 4 for snow
type=1
#cloud -0 for all (cloudy and clear) radiances, 1 for clear FOVs, 2 for clear channels, 3 for cloudy FOVs
cloud=1
#absolute value of the maximum allowable sensor zenith angle (degrees)
angle=20
#option to output the channel wavenumbers
wave_out=.true.
#option to output the assigned observation errors
err_out=.true.
#option to output the correlation matrix
corr_out=.true.
#condition number to recondition Rcov.  Set <0 to not recondition
kreq=60
#logical to use modified Rcov
mod_Rcov=.true.
ndate=/da/save/Kristen.Bathmann/anl_tools/ndate

####################

cdate=$bdate
[ ! -d ${wrkdir} ] && mkdir ${wrkdir}
[ ! -d ${savdir} ] && mkdir ${savdir}
cp fast_cov_calc $wrkdir
nt=0
cd $wrkdir
while [[ $cdate -le $edate ]] ; do
   while [[ ! -f $diagdir/radstat.gdas.$cdate ]] ; do 
     cdate=`$ndate +06 $cdate`
     if [ $cdate -gt $edate ] ; then
        break
     fi
   done
   nt=`expr $nt + 1`
   if [ $nt -lt 10 ] ; then
      fon=000$nt
   elif [ $nt -lt 100 ] ; then
      fon=00$nt
   elif [ $nt -lt 1000 ] ; then
      fon=0$nt
   else
      fon=$nt
   fi
   if [ ! -f danl_${fon} ];
   then
      cp $diagdir/radstat.gdas.$cdate .
      tar -xvf radstat.gdas.$cdate
      gunzip *.gz
      rm radstat.gdas.$cdate
      if [ -f diag_${instr}_anl.${cdate} ];
      then
         mv diag_${instr}_anl.${cdate} danl_${fon}
         mv diag_${instr}_ges.${cdate} dges_${fon}
      else
         nt=`expr $nt - 1`
      fi
      rm diag*
   fi
   cdate=`$ndate +06 $cdate`
done
./fast_cov_calc <<EOF
$nt $type $cloud $angle $instr $wave_out $err_out $corr_out $kreq $mod_Rcov
EOF

cp Rcov_$instr $savdir

[ -f Rcorr_$instr ] && cp Rcorr_$instr $savdir
[ -f wave_$instr ] && cp wave_$instr $savdir
[ -f err_$instr ] && cp err_$instr $savdir
