----------------------- HOW TO INSTALL -----------------------

Open your command invit:
Type : pip install read_zrsc2019

--------------------------- ERRORS ---------------------------

read.py checks each line in each file and can return several errors :

"File cannot contain just time" :
    This means one of your file contains only time and not symbols.

"Inconsistent format (with time)" :
    Your file is supposed to contain time but one of the line doesn't (missing ":" for example)

"Inconsistent format, vector size changed" :
    Your symbol representation changed from one line to another
    Typically your vector changed size

"Start time of this line must correspond to endtime of precedent line":
    Your offset timing of a symbol on line i does not match with the onset timing of next symbol.

"Conversion to vector impossible, could not convert to float":
    - Your symbol is a str and is separated by spaces
    - Your symbol is a vector that does not contain numbers at some point

"File is empty":
    One of your file is empty

"WARNING : Your files do not have the same format" :
    This message appears if your files do not have the same format from one to another.
