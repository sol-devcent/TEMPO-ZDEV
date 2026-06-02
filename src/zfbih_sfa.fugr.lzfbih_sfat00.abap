*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBIH_SFA.......................................*
DATA:  BEGIN OF STATUS_ZFBIH_SFA                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBIH_SFA                     .
CONTROLS: TCTRL_ZFBIH_SFA
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFBIH_SFA                     .
TABLES: ZFBIH_SFA                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
