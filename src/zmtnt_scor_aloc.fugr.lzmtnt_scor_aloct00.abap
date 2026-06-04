*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMTNT_SCOR_ALOC.................................*
DATA:  BEGIN OF STATUS_ZMTNT_SCOR_ALOC               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMTNT_SCOR_ALOC               .
CONTROLS: TCTRL_ZMTNT_SCOR_ALOC
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZMTNT_SCOR_ALOC               .
TABLES: ZMTNT_SCOR_ALOC                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
