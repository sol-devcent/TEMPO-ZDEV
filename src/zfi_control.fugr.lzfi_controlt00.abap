*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CONTROL.....................................*
DATA:  BEGIN OF STATUS_ZFI_CONTROL                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CONTROL                   .
CONTROLS: TCTRL_ZFI_CONTROL
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFI_CONTROL                   .
TABLES: ZFI_CONTROL                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
