*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_MAP1....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_MAP1                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_MAP1                  .
CONTROLS: TCTRL_ZFGSCAB_MAP1
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_MAP1                  .
TABLES: ZFGSCAB_MAP1                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
