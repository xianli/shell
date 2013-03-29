#!/bin/ksh
#**********************************************************************/
#
# Name  : run_rms_final.ksh
#
# Author: Mike Landry
#
# Desc  : shell script used to Process the data in dwdm1.rms
#
#**********************************************************************/
#

trap "" 1

if [ $0 = run_rms_final.ksh -o $0 = ./run_rms_final.ksh ]
then
  WRKDIR=`pwd`
else
  WRKDIR=$0
fi

PROF_DIR=`echo $WRKDIR | cut -d/ -f1-3`
. $PROF_DIR/.profile
. $PROF_DIR/RMS/.profile_RMS

#/home/dw_oper/RMS/scripts/extra_3am.sh

typeset -i cnt=1
typeset -i st=0
# Check the input parameters ..........

while getopts sf: opt
do
  case $opt in
     s) st=1;;
     f) LOG=$OPTARG;;
     ?) printf "Usage: %s: [-s (bypass process_files.ksh)] -f LOG_NAME  \n" $0
esac
done

if [[ -z $LOG ]]
then
        echo 'run_rms_renewal.ksh [-s] LOG_NAME (LOG file name missing.)'
        exit 5
fi

email_list=${RMS_CFG_DIR}/opr_list
err_list=${RMS_CFG_DIR}/err_list
stamp=$(date "+%Y%m%d%H%M")
logfile=${LOG}_$stamp
clnt_logfile=${RMS_LOG_DIR}/${LOG}_$stamp

mailto () {
        for addr in `cat $1`
        do
           subject=${HOST_NAME}:${3}
           log_file=${2}
           if [ -f ${log_file} ]
           then
             mailx -s "${subject}" ${addr} < ${log_file}
           else
             echo "Check the log from ${RMS_LOG_DIR} directory" | mailx -s "${subject}" ${addr}
           fi
        done
}
#echo "Log file Name : " ${clnt_logfile} >> ${clnt_logfile}
#echo "SP DP_INSRT_MAINTRENWLACTLFACT started at: "`date` >> ${clnt_logfile}

#${ODS_BIN_DIR}/run_sp -A -RV -p DP_INSRT_MAINTRENWLACTLFACT "${DB2_PRT_DIR}/${logfile}"

#rstatus=$?

#echo "---Begin Stored Procedure Log---" >> ${clnt_logfile}
#echo "" >> ${clnt_logfile}

#cat ${DB2_LOG_DIR}/${logfile} >> ${clnt_logfile}

#echo "" >> ${clnt_logfile}
#echo "---End Stored Procedure Log---" >> ${clnt_logfile}

#echo "SP DP_INSRT_MAINTRENWLACTLFACT ended at: "`date`  >>${clnt_logfile}

#if [ ${rstatus} -ne 0 ]
#then
#   echo "ODS-ERR: DP_INSRT_MAINTRENWLACTLFACT failed at : "`date`>>${clnt_logfile}
#   mailto $err_list "$clnt_logfile" "RMS-Actual Refresh failed"
#   exit 9
#else
#   echo "ODS-INFO: DP_INSRT_MAINTRENWLACTLFACT successful at : "`date`>>${clnt_logfile}
#   mailto $email_list "$clnt_logfile" "RMS-Actual refresh completed sucessfully"
#fi

echo "SP dp_insrt_maint_renwl_trgt_actl_fact  started at: "`date` >> ${clnt_logfile}

stamp=$(date "+%Y%m%d%H%M")
logfile=${LOG}_$stamp

${ODS_BIN_DIR}/run_sp -A -RV -p DP_INSRT_MAINT_RENWL_TRGT_ACTL_FACT "${DB2_PRT_DIR}/${logfile}"
rstatus=$?

echo "SP DP_INSRT_MAINT_RENWL_TRGT_ACTL_FACT ended at: "`date`  >>${clnt_logfile}

echo "---Begin Stored Procedure Log---" >> ${clnt_logfile}
echo "" >> ${clnt_logfile}

cat ${DB2_LOG_DIR}/${logfile} >> ${clnt_logfile}

echo "" >> ${clnt_logfile}
echo "---End Stored Procedure Log---" >> ${clnt_logfile}

echo "Process status of the return code = "${rstatus} >> ${clnt_logfile}

if [ ${rstatus} -eq 0 ]
then
   #touch /job_cntl/temp_files/rmsdone
   touch ${DONEFILE}
   echo "dp_insrt_maint_renwl_trgt_actl_fact completed successfully at : "`date`>>${clnt_logfile}
   mailto $email_list "$clnt_logfile" "RMS-Final fact refresh completed successfully"
else
   echo "ODS-ERR: DP_INSRT_MAINT_RENWL_TRG_FACT4 failed at:"`date`>>${clnt_logfile}
   mailto $err_list "$clnt_logfile" "RMS-ERR-Final fact refresh failed"
   exit 9
fi

exit 0