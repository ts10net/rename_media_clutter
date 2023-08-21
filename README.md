# rename_media_clutter
This script renames media files in a given directory based on the creation date and time in their file name, and adds prefixes "P_" for pictures and "V_" for audio/video files for easy identification. It can also move files to a destination folder.

## Author
Tushar Sharma

## Version History

### 3.1
- removed version number from the script name

    #### Parameters
    -s source_folder [-d destination_folder] [-w (yes|no)]

    #### Usage
    ```sh
    ./rename_media_clutter.sh -s source_folder [-d destination_folder] [-w (yes|no)]
    
    Options:
    -s     Specify the source folder containing media files.
    -d     Specify a destination folder to move renamed files.
    -w     Show a warning prompt before proceeding (default: yes).
    ```

### 3.0
- files moved into destination location under year-wise sub directories followed by month in yyyy/MM_MMM format

    #### Parameters
    -s source_folder [-d destination_folder] [-w (yes|no)]

    #### Usage
    ```sh
    ./rename_media_clutter_v.3.0.sh -s source_folder [-d destination_folder] [-w (yes|no)]
    
    Options:
    -s     Specify the source folder containing media files.
    -d     Specify a destination folder to move renamed files.
    -w     Show a warning prompt before proceeding (default: yes).
    ```

    #### Example
        WARNING: This script will rename and potentially move files. Do you want to proceed? (y/n): 
        
        2020-12-15 05.06.07.jpg -> 2020\12_Dec\P_20201215_050607.jpg

### 2.1
- added warning message in the beginning of script run
- progress bar shown in percentage of files processed

    #### Parameters
    -s source_folder [-d destination_folder] [-w (yes|no)]

    #### Usage
    ```sh
    ./rename_media_clutter_v.2.1.sh -s source_folder [-d destination_folder] [-w (yes|no)]
    
    Options:
    -s     Specify the source folder containing media files.
    -d     Specify a destination folder to move renamed files.
    -w     Show a warning prompt before proceeding (default: yes).
    ```

    #### Example
        WARNING: This script will rename and potentially move files. Do you want to proceed? (y/n): 

### 2.0
- added source and destination directories as input parameters
- included headers on main log

    #### Usage
    ```sh
    ./rename_media_clutter_v.2.1 -s ~/Pictures/Summer -d ~/Pictures/Organized
    ```

### 1.0
- initial version to rename media files in a given directory
- suffix with 4 digit sequence number if new filename exist at destination
- logs save under logs/main_log_x and logs/error_logs_x
- supported file types
    - Pictures: "heic" "jpg" "jpeg" "png" "gif"
    - Videos: "mov" "avi" "mp4" "mts" "mpg" "3gp"
- input file format 'yyyy-MM-dd HH.mm.ss'
- output file format 'yyyyMMdd_HHmmss'

    #### Example
        2020-12-15 05.06.07.jpg -> P_20201215_050607.jpg
        2020-12-30 08.09.10.mp4 -> V_20201230_080910.mp4
  
    #### Usage
    ```sh
    ./rename_media_clutter_v.1.0 ~/Pictures/Summer
    ```

