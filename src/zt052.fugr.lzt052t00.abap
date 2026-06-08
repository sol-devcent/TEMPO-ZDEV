*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZT052...........................................*
DATA:  BEGIN OF STATUS_ZT052                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZT052                         .
CONTROLS: TCTRL_ZT052
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZT052                         .
TABLES: ZT052                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
