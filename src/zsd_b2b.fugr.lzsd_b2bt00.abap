*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_B2B.........................................*
DATA:  BEGIN OF STATUS_ZSD_B2B                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_B2B                       .
CONTROLS: TCTRL_ZSD_B2B
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSD_B2B                       .
TABLES: ZSD_B2B                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
