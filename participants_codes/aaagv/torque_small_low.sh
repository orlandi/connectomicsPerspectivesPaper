#!/bin/bash
#PBS -l nodes=1:ppn=2
#PBS -l walltime=48:00:00
#PBS -t 451-500
#PBS -l cput=48:00:00
#PBS -e logs/${PBS_JOBID}.err
#PBS -o logs/${PBS_JOBID}.out

sleep `expr $RANDOM % 10`
EXEC="python main.py"
FOLDER="/home/users/orlandi/research/connectomicsPerspectivesPaper/datasets/small/low-bursting"
OUTPUT_FOLDER="/home/users/orlandi/research/connectomicsPerspectivesPaper/participants_results/aaagv/small/low-bursting"
NETWORK="N100_CC05_${PBS_ARRAYID}"
FLUORESCENCE_FILE="fluorescence_${NETWORK}.txt"
EXEC_PARAMS="--directivity 1 --fluorescence ${FOLDER}/${FLUORESCENCE_FILE} --method tuned --network ${NETWORK} --output_dir ${OUTPUT_FOLDER}"


cd $PBS_O_WORKDIR
OMP_NUM_THREADS=$PBS_NUM_PPN
export OMP_NUM_THREADS

##########################################
#                                        #
#   Output some useful job information.  #
#                                        #
##########################################

echo ------------------------------------------------------
echo -n 'Job is running on node '; cat $PBS_NODEFILE
echo ------------------------------------------------------
echo PBS: qsub is running on $PBS_O_HOST
echo PBS: originating queue is $PBS_O_QUEUE
echo PBS: executing queue is $PBS_QUEUE
echo PBS: working directory is $PBS_O_WORKDIR
echo PBS: execution mode is $PBS_ENVIRONMENT
echo PBS: job identifier is $PBS_JOBID
echo PBS: job name is $PBS_JOBNAME
echo PBS: node file is $PBS_NODEFILE
echo PBS: current home directory is $PBS_O_HOME
echo PBS: PATH = $PBS_O_PATH
echo PBS: EXEC = ${EXEC} ${EXEC_PARAMS}
echo ------------------------------------------------------

${EXEC} ${EXEC_PARAMS}

