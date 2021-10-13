#!/bin/bash


# Window configuration:
YAD_WIDTH="700"
YAD_TITLE="JovarkOS Configuration"


dateNow=$(date +"%F_%R")
# Start new entry in log with a filename such as 'install-2021-10-13_18:32.log'
echo "===== $(date) log: =====" > install-$dateNow.log

# Ask via checklist of programs to install
yad --list \
--title="$YAD_TITLE" --center --width="$YAD_WIDTH" --height="700" \
--checklist \
--separator="," \
--column="Select" \
--column="Type" \
--column="Name" \
--column="Description" \
FALSE 'Package Manager' 'gimp' 'GNU Image Manipulation Program' \
TRUE 'Package Manager' 'flatpak' 'Linux application sandboxing and distribution framework' \
| sed 's/ /_/g' | awk -F, '{ print $3 }' > pkg_selected.tmp

# Write packages selected to log file
echo "Installing: " >> install-$dateNow.log
for i in `cat pkg_selected.tmp`
do
   echo "  -" $i >> install-$dateNow.log
done

# ask for password without outputting it to console
PASSWORD=`yad --title="$YAD_TITLE" --form --separator="" --field="Enter the root Password:H" --center`

case $? in
         0)
              # These () are needed for the progress bar to pulsate
              (
              echo "0"; echo "0: Asking for password with yad..." # >> install-$dateNow.log
              echo $PASSWORD | sudo -S pacman --noconfirm -S $(awk '{print $1}' pkg_selected.tmp)
              ) |
              yad --progress --title="$YAD_TITLE" --text="Installing $(cat pkg_selected.tmp)..." \
              --pulsate --width="$YAD_WIDTH" --auto-close --on-top \
              --text-align=center --center >> install-$dateNow.log

              # Use the escape; shows te familiar check mark
              yad --title="$YAD_TITLE" --text="Installation Complete" --button=\!gtk-apply:0 --width="$YAD_WIDTH" --center
              echo "Done installing packages..." >> install-$dateNow.log
              
              # Unset PASSWORD variable before anything else happens
              unset PASSWORD
              echo "Unset variable storing password..." >> install-$dateNow.log
              ;;
         1)
                echo "1: Stopped login..." >> install-$dateNow.log;;
        -1)
                echo "-1: An unexpected error has occurred. Please check the log at install-$dateNow.log";;
esac


