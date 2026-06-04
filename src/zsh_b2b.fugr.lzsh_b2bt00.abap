*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSH_B2B.........................................*
DATA:  BEGIN OF STATUS_ZSH_B2B                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSH_B2B                       .
CONTROLS: TCTRL_ZSH_B2B
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSH_B2B                       .
TABLES: ZSH_B2B                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
