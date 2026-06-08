*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZT16FW..........................................*
DATA:  BEGIN OF STATUS_ZT16FW                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZT16FW                        .
CONTROLS: TCTRL_ZT16FW
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZT16FW                        .
TABLES: ZT16FW                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
