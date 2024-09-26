## Installer-SH

https://github.com/Shedou/Chimbalix-Software-Catalog

The version and hints are in the file "install.sh".

### Usage:

Normal installation, just run:

`install.sh`

Silent installation, no output if everything is installed without errors:

`install.sh -silent`

### Creating installation packages (v1.6):

1) Delete all unnecessary example files in the "program_files" directory except uninstall.sh and icon-uninstall.png, and also delete the archives in the "installer-data" directory.
2) The "user_files" directory should be deleted if it is not needed.
3) Place the application files in the "program_files" directory.
4) Configure the menu files according to the application in the directory "system_files/menu/apps/UNIQUE_APP_FOLDER_NAME/".
5) If everything is set up correctly, you can pack the archives using "pack_archives_for_small_apps.sh" or "pack_archives.sh" depending on the size of the application.
6) Then configure the "install.sh" file and fill in the application information.
7) Checking that everything worked correctly.
8) If everything is correct, in the "installer-data" directory, delete everything except the "tools" folder and the "program_files.7z / system_files.7z" archives
9) Checking that everything worked correctly.
