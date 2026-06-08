*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSFLAGTYPE....................................*
DATA:  BEGIN OF STATUS_ZFGSFLAGTYPE                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSFLAGTYPE                  .
CONTROLS: TCTRL_ZFGSFLAGTYPE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSFLAGTYPE                  .
TABLES: ZFGSFLAGTYPE                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
