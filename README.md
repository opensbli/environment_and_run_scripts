# How to use workflow scripts

> These set scripts are intended to automatically set up an environment both using and developing OpenSBLI. However, they could also be utilised separately for installing [OPS](https://github.com/OP-DSL/OPS) library, HDF5 library, and create an independent Python environment.

- Tools needed for scripts.
  These workflow scripts will require the following tools pre-installed:

  - unzip
  - wget
  - sed
  - CMake (**version>=3.18**)
  - Python (**version>=3.8**)

  If you are installing, say Python3.12, please ensure you install the corresponsing virtual environment module using, e.g. on Ubuntu Machine **apt install Python3.12-venv**. You may need to use sudo if you are not the root user. Also, please ensure in your /usr/bin folder that the **python3** is pointing to, in this case, **python3.12**. venv is used to create isolated virtual environments for Python projects. Without this package, commands like "python3.12 -m venv myenv" may not work.
  
  In general, we only need to take care of CMake where we will need CMake version **higher than 3.18**. If the default CMake provided by the system cannot satisfy this, we provide InstallCMake.sh to download and install CMake with a specified version. Assuming we would like to install Version 3.22.2

  ```bash
  # install CMake into /usr/local/CMake
  sudo ./InstallCMake.sh -v 3.22.2 -s
  # install CMake into $HOME/CMake
  ./InstallCMake.sh -v 3.22.2
  # install CMake into $HOME/tmp/CMake
  ./InstallCMake.sh -v 3.22.2 -d $HOME/tmp/CMake

  ```
  After installation, the script will add the a link to cmake into /usr/loca/bin/ or $HOME/bin
- Create the environment and compile

  - Step 1 Create the environment

    Copy CreateOpenSBLIEnv.sh into a directory, make it executable and run, for example, to create an environment including Python3/2, OPS.

    ```bash
    wget -c https://raw.githubusercontent.com/opensbli/environment_and_run_scripts/refs/heads/main/CreateOpenSBLIEnv.sh
    chmod a+x CreateOpenSBLIEnv.sh
    ```

    We note that the first argument of the script (i.e., the directory) must use an **absolute path**.

    By default, the OPS library, the Python environment, and the OpenSBLI framework are installed inside the directory. If required, a local HDF5 can also be installed.

    ```bash
    ./CreateOpenSBLIEnv.sh -d ~/tmp/OpenSBLIEnv
    ```
    During the creation, the script will assume all dependencies are ready by default. But we also provide help on installing these dependencies for a few Linux distributions and clusters, e.g.,

    ```bash
    ./CreateOpenSBLIEnv.sh -d ~/tmp/OpenSBLIEnv -m Archer2
    ```
  - Step 2 Generate C/C++ codes for an application

    By default, Generate.sh will set the directory where it is to be the environment directory. It will activate the Python environment in the environment and translate the specified OpenSBLI Python source code.

    ```bash
    # assuming under the environment directory
    cd OpenSBLI/apps/transitional_SBLI/
    ../../../Generate.sh transitional_SBLI.py
    ```
  - Step 3 Compile the C/C++ code

    When creating the environment at Step 1, the default machine in CompileC.sh will be set to the intended one. Also, CompileC.sh will set the directory where it is to be the environment directory and use the local HDF5 at the first instance.

    ```bash
    #  # assuming under the environment directory
    cd OpenSBLI/apps/transitional_SBLI/
    ../../../CompileC.sh
    ```
  - Step 4 Optional setup

    After successfully compiling and installing everything, the script will indicate that we can use set up a few more environment variables by "source" the script OpenSBLIEnvVar under the specified directory (say ~/tmp/OpenSBLIEnv). It will set up the $PATH so that we can run Generate.sh and CompileC.sh without "../../../". Also, one can call source $PYTHON to enter into the provided Python environment for postprocessing.

- Generate the submission script for supercomputers

  The capability is implemented by using Python 3. It requires two packages which are not shipped with Python 3 by default, i.e., Jinja2 and commentjson. The two packages are installed by default for the Python package installed with InstallPython.sh. The script will automatically install them if they are not detected.

  To use the script, we need to specify the job in a JSON format file, say "JobSubmission.json"

  ```json
  {
    "Machine":"ARCHER2",
    "Nodes" : 64,
    "TasksPerNode":128,
    "CpusPerTask":1,
    "JobName":"TGV",
    "Account":"c01-eng",
    "QoS":"standard",
    "Partition": "standard",
    "Time": "00:10:00",#HH:MM:SS
    "Program":"./TGV3DMpi Config=tgv3d1024.json"
  }
  ```
  and then run the script to generate the submission script accordingly

  ```bash
  Submit.py JobSubmission.json
  ```
- Tips

  - There is an explanation on usage in each script, which can be shown by, e.g.,

    ```bash
      ./InstallCMake.sh -h
    ```
