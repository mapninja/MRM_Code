    find /Users/maples/Scratch/MRM/data/v3/combined -type f -print | while read -r file; do 
    gzip "$file"; 
    done 