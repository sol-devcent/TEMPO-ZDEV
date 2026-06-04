*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSB2B_ERRLOG....................................*
DATA:  BEGIN OF STATUS_ZSB2B_ERRLOG                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSB2B_ERRLOG                  .
CONTROLS: TCTRL_ZSB2B_ERRLOG
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSB2B_ERRLOG                  .
TABLES: ZSB2B_ERRLOG                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
