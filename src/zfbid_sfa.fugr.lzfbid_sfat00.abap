*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBID_SFA.......................................*
DATA:  BEGIN OF STATUS_ZFBID_SFA                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBID_SFA                     .
CONTROLS: TCTRL_ZFBID_SFA
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFBID_SFA                     .
TABLES: ZFBID_SFA                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
