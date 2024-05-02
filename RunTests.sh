#!/bin/bash
##@brief run the OpenSBLI integration tests
##@author Edward Parkinson
##@contributors
##@details

function usage {
    echo "This script will run the integration tests for OpenSBLI!"
    echo "./$(basename $0) -h -> showing usage"
    echo "./$(basename $0) -H -> Specifying the HDF5 directory"
    echo "./$(basename $0) -e -> Sepcifying the environment directory."
    echo "./$(basename $0) -m -> Specifying the machine type"
    echo "Machine type can be: Ubuntu ARCHER2 IRIDIS5 Fedora DAaaS"
    echo "If without specifying the machine, the script will assume all dependencies prepared!"
}

Machine="None"
ScriptPath="${BASH_SOURCE:-$0}"
AbsolutScriptPath="$(realpath "${ScriptPath}")"
EnvDir="$(dirname "${AbsolutScriptPath}")"

if [ -d "${EnvDir}/HDF5" ]
then
    export HDF5_INSTALL_PATH="${EnvDir}/HDF5"
fi

optstring="e:m:H:h"

while getopts ${optstring} options; do
    case ${options} in
        h)
            usage
            exit 0
        ;;
        H)
            export HDF5_INSTALL_PATH="${EnvDir}/HDF5"
        ;;
        e)
            EnvDir=${OPTARG}
        ;;
        m)
            Machine=${OPTARG}
        ;;
        :)
            echo "$0: Must supply an argument to -$OPTARG." >&2
            exit 1
        ;;
        ?)
            echo "Invalid option: -${OPTARG}."
            exit 2
        ;;
    esac
done

if [ $Machine == "CIRRUS" ]
then
    module load nvidia/nvhpc
    module load cmake/3.22.1
    if [ -z ${HDF5Root} ]
    then
        module load hdf5parallel/1.12.0-nvhpc-openmpi
    fi
fi

if [ $Machine == "ARCHER2" ]
then
    module purge PrgEnv-cray
    module load load-epcc-module
    module load cmake/3.21.3
    module load PrgEnv-gnu

    if [ -z ${HDF5Root} ]
    then
        module load cray-hdf5-parallel
    fi
fi

if [ $Machine == "IRIDIS5" ]
then
    module load gcc/6.4.0
    if [ -z ${HDF5Root} ]
    then
        module load hdf5/1.10.2/gcc/parallel
    fi
    module load cuda/10.0
    module load cmake
fi

source ${EnvDir}/Python/bin/activate "${EnvDir}/Python"
export OPS_INSTALL_DIR=$EnvDir/OPS-INSTALL
export OPS_TRANSLATOR=$OPS_INSTALL_DIR/bin/ops_translator/c
export PYTHONPATH=$PYTHONPATH:$EnvDir/OpenSBLI

python test_opensbli.py
