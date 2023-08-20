# rename_media_clutter
This script renames media files in a given directory based on the creation date and time in their file name, and adds prefixes "P_" for pictures and "V_" for audio/video files for easy identification.

## Author
Tushar Sharma

## Version History

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
