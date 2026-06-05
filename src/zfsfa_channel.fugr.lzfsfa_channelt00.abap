*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFSFA_CHANNEL...................................*
DATA:  BEGIN OF STATUS_ZFSFA_CHANNEL                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFSFA_CHANNEL                 .
CONTROLS: TCTRL_ZFSFA_CHANNEL
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFSFA_CHANNEL                 .
TABLES: ZFSFA_CHANNEL                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
