*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMAPPING_AUGRU.................................*
DATA:  BEGIN OF STATUS_ZSMAPPING_AUGRU               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMAPPING_AUGRU               .
CONTROLS: TCTRL_ZSMAPPING_AUGRU
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSMAPPING_AUGRU               .
TABLES: ZSMAPPING_AUGRU                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
